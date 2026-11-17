import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../services/royalty_free_media_service.dart';
import '../widgets/effects_gallery_sheet.dart';
import '../widgets/sound_picker_sheet.dart';
import 'post_video_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  CameraLensDirection _currentDirection = CameraLensDirection.back;

  bool _isInitializing = true;
  bool _permissionDenied = false;
  bool isSimulated = false;
  bool _isRecording = false;
  bool _isPickingFromGallery = false;
  bool _returningFromSettings = false;
  bool _hasShownSettingsDialog = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  String _selectedTime = '15 s';

  // Estados solicitados para Audio y Efecto Visual
  String? selectedAudioUrl;
  String? selectedAudioName;
  String? selectedEffectId = 'Ninguno';

  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoEffectOverlay? _selectedEffect;
  VideoPlayerController? _effectController;
  bool _isEffectReady = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isSimulated = false;
    _requestPermissionsAndInitCamera(showFeedbackOnDeny: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (state == AppLifecycleState.inactive) {
      if (cameraController != null && cameraController.value.isInitialized) {
        cameraController.dispose();
        _controller = null;
      }
      _effectController?.pause();
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_returningFromSettings) {
        _returningFromSettings = false;
        _recheckPermissionsAfterSettings();
      } else if (!isSimulated && _controller == null && !_permissionDenied) {
        _requestPermissionsAndInitCamera(showFeedbackOnDeny: false);
      }
      if (_isEffectReady) {
        _effectController?.play();
      }
      if (selectedAudioUrl != null) {
        _audioPlayer.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _audioPlayer.dispose();
    _effectController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _stopCameraAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playSelectedSoundInLoop(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E1E1E),
          content: Text('No se pudo reproducir el audio seleccionado: $e'),
        ),
      );
    }
  }

  Future<void> _applyVisualEffect(VideoEffectOverlay? effect) async {
    final VideoPlayerController? oldController = _effectController;
    setState(() {
      selectedEffectId = effect?.id ?? 'Ninguno';
      _selectedEffect = effect;
      _effectController = null;
      _isEffectReady = false;
    });
    await oldController?.dispose();

    if (effect == null) return;

    final VideoPlayerController nextController =
        VideoPlayerController.networkUrl(Uri.parse(effect.videoUrl));
    try {
      await nextController.initialize();
      await nextController.setLooping(true);
      await nextController.setVolume(0.0);
      await nextController.play();
      if (!mounted) {
        await nextController.dispose();
        return;
      }
      setState(() {
        _effectController = nextController;
        _isEffectReady = true;
      });
    } catch (_) {
      await nextController.dispose();
    }
  }

  bool get _hasActiveEffect =>
      selectedEffectId != null && selectedEffectId != 'Ninguno';

  ColorFilter get _activeCameraColorFilter {
    switch (selectedEffectId) {
      case 'light_leaks':
        return const ColorFilter.mode(
          Color(0x55FF6B35),
          BlendMode.softLight,
        );
      case 'neon_particles':
        return const ColorFilter.mode(
          Color(0x4425F4EE),
          BlendMode.screen,
        );
      case 'bokeh_nights':
        return const ColorFilter.mode(
          Color(0x557C3AED),
          BlendMode.softLight,
        );
      case 'vhs_retro':
        return const ColorFilter.mode(
          Color(0x55F59E0B),
          BlendMode.color,
        );
      default:
        return const ColorFilter.mode(
          Colors.transparent,
          BlendMode.dst,
        );
    }
  }

  /// Overlay visual en tiempo real sobre CameraPreview (ColorFiltered + BlendMode.screen + VideoPlayer MP4)
  Widget _buildCameraEffectLayer() {
    if (!_hasActiveEffect) return const SizedBox.shrink();

    final String effectId = selectedEffectId!;
    final List<Color> gradientColors;

    switch (effectId) {
      case 'light_leaks':
        gradientColors = const [
          Color(0xAAFF6B35),
          Color(0x44FF2E63),
          Color(0x00000000),
          Color(0x77FFB703),
        ];
        break;
      case 'neon_particles':
        gradientColors = const [
          Color(0x8825F4EE),
          Color(0x44673AB7),
          Color(0x88FE2C55),
        ];
        break;
      case 'bokeh_nights':
        gradientColors = const [
          Color(0x88E91E63),
          Color(0x447C3AED),
          Color(0x6638BDF8),
        ];
        break;
      case 'vhs_retro':
      default:
        gradientColors = const [
          Color(0x66F59E0B),
          Color(0x3310B981),
          Color(0x66EF4444),
        ];
        break;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Capa luminosa con BlendMode.screen sobre el CameraPreview
            Opacity(
              opacity: 0.42,
              child: Container(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.screen,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
              ),
            ),

            // Overlay de video MP4 transparente en bucle
            if (_isEffectReady && _effectController != null)
              Opacity(
                opacity: 0.40,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _effectController!.value.size.width > 0
                        ? _effectController!.value.size.width
                        : 1080,
                    height: _effectController!.value.size.height > 0
                        ? _effectController!.value.size.height
                        : 1920,
                    child: AspectRatio(
                      aspectRatio: _effectController!.value.aspectRatio > 0
                          ? _effectController!.value.aspectRatio
                          : 9 / 16,
                      child: VideoPlayer(_effectController!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPermanentPermissionDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Permiso requerido',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Ve a Ajustes para habilitar la cámara y el micrófono.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _returningFromSettings = true;
                Navigator.pop(dialogContext);
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE2C55),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ir a Ajustes'),
            ),
          ],
        );
      },
    );
  }

  /// Re-evalúa permisos al volver desde los Ajustes del sistema (AppLifecycleState.resumed)
  Future<void> _recheckPermissionsAfterSettings() async {
    final PermissionStatus cameraStatus = await Permission.camera.status;
    final PermissionStatus micStatus = await Permission.microphone.status;

    if (!mounted) return;

    if (!cameraStatus.isGranted) {
      setState(() {
        _isInitializing = false;
        _permissionDenied = true;
        isSimulated = false;
      });
      return;
    }

    await _initializeAvailableCamera(micGranted: micStatus.isGranted);
  }

  // 1. Solicitar Permission.camera + Permission.microphone (permission_handler), manejar permanentlyDenied -> openAppSettings() y denied -> aviso nativo
  Future<void> _requestPermissionsAndInitCamera({
    bool showFeedbackOnDeny = true,
  }) async {
    setState(() {
      _isInitializing = true;
      _permissionDenied = false;
      isSimulated = false;
    });

    final PermissionStatus cameraStatus = await Permission.camera.request();
    final PermissionStatus micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _permissionDenied = true;
        isSimulated = false;
      });

      if (cameraStatus == PermissionStatus.permanentlyDenied ||
          cameraStatus.isRestricted) {
        if (showFeedbackOnDeny) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFDC2626),
              content: Text(
                'Abre los ajustes y activa los permisos de cámara',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          _returningFromSettings = true;
          await openAppSettings();
        } else if (!_hasShownSettingsDialog) {
          _hasShownSettingsDialog = true;
          await _showPermanentPermissionDialog();
        }
      } else if (cameraStatus == PermissionStatus.denied && showFeedbackOnDeny) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF1E1E1E),
            content: Text(
              'Acepta el permiso de cámara en la ventana del sistema para continuar.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return;
    }

    await _initializeAvailableCamera(micGranted: micStatus.isGranted);
  }

  Future<void> _initializeAvailableCamera({required bool micGranted}) async {
    try {
      _cameras = await availableCameras();

      // Solo si no existe ninguna cámara física en el dispositivo, mostrar fondo negro sin texto simulado
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _permissionDenied = false;
          isSimulated = true;
        });
        return;
      }

      // Hay cámaras físicas: inicializar CameraController y asegurar isSimulated = false
      await _initializeController(
        _cameras.first,
        enableAudio: micGranted,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _permissionDenied = true;
        isSimulated = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar la cámara física: $e')),
      );
    }
  }

  Future<void> _closeCamera() async {
    _recordTimer?.cancel();
    await _stopCameraAudio();
    final CameraController? activeController = _controller;
    _controller = null;
    await activeController?.dispose();
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  Future<void> _initializeController(
    CameraDescription description, {
    bool enableAudio = true,
  }) async {
    final CameraController? previousController = _controller;

    final CameraController newController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: enableAudio,
    );

    if (mounted) {
      setState(() {
        _isInitializing = true;
        _controller = null;
        isSimulated = false;
      });
    }

    await previousController?.dispose();

    try {
      await newController.initialize();
      if (!mounted) {
        await newController.dispose();
        return;
      }
      setState(() {
        _controller = newController;
        _currentDirection = description.lensDirection;
        _permissionDenied = false;
        isSimulated = false;
        _isInitializing = false;
      });
    } catch (e) {
      await newController.dispose();
      // Reintentar con resolución media sin bloquear la cámara física si high falla
      final CameraController fallbackController = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      try {
        await fallbackController.initialize();
        if (!mounted) {
          await fallbackController.dispose();
          return;
        }
        setState(() {
          _controller = fallbackController;
          _currentDirection = description.lensDirection;
          _permissionDenied = false;
          isSimulated = false;
          _isInitializing = false;
        });
      } catch (_) {
        await fallbackController.dispose();
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _permissionDenied = true;
          isSimulated = false;
        });
      }
    }
  }

  // 2. Botón Voltear Cámara (trasera <-> frontal)
  Future<void> _flipCamera() async {
    if (_isRecording || _isInitializing || _cameras.isEmpty) return;

    final CameraLensDirection targetDirection =
        _currentDirection == CameraLensDirection.back
            ? CameraLensDirection.front
            : CameraLensDirection.back;

    final int targetIndex = _cameras.indexWhere(
      (cam) => cam.lensDirection == targetDirection,
    );

    if (targetIndex == -1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró una cámara frontal disponible'),
        ),
      );
      return;
    }

    final bool micGranted = await Permission.microphone.isGranted;
    await _initializeController(
      _cameras[targetIndex],
      enableAudio: micGranted,
    );
  }

  // 4. Pasar audioUrl, audioName y effectUsed a PostVideoScreen
  Future<void> _navigateToPostVideo(String videoPath) async {
    await _stopCameraAudio();
    await _effectController?.pause();
    if (!mounted) return;

    final bool? published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PostVideoScreen(
          videoPath: videoPath,
          audioName: selectedAudioName,
          audioUrl: selectedAudioUrl,
          effectUsed: _hasActiveEffect ? (_selectedEffect?.name ?? selectedEffectId) : 'Ninguno',
          effectVideoUrl: _selectedEffect?.videoUrl,
        ),
      ),
    );
    if (mounted && published == true) {
      Navigator.pop(context, true);
    } else if (mounted) {
      if (_isEffectReady) {
        await _effectController?.play();
      }
      if (selectedAudioUrl != null) {
        await _playSelectedSoundInLoop(selectedAudioUrl!);
      }
    }
  }

  Future<void> _continueWithoutCamera() async {
    const String samplePreviewUrl =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4';
    await _navigateToPostVideo(samplePreviewUrl);
  }

  // 3. Botón Grabar / Detener Video con hardware real
  Future<void> _toggleRecording() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (!_isRecording) {
      try {
        await controller.startVideoRecording();
        _recordTimer?.cancel();
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => _recordSeconds++);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo iniciar la grabación: $e')),
        );
      }
    } else {
      _recordTimer?.cancel();
      try {
        final XFile recordedFile = await controller.stopVideoRecording();
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath =
            '${tempDir.path}/viroklipz_${DateTime.now().millisecondsSinceEpoch}.mp4';
        String finalPath = recordedFile.path;
        try {
          await recordedFile.saveTo(tempPath);
          finalPath = tempPath;
        } catch (_) {}

        if (!mounted) return;
        setState(() => _isRecording = false);

        await _navigateToPostVideo(finalPath);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el video: $e')),
        );
      }
    }
  }

  String _formatTimer(int totalSeconds) {
    final String mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final String secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _showGalleryPermissionDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Permiso de galería requerido',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Para elegir videos de tu galería, otorga permiso de acceso a fotos y videos en los ajustes del teléfono.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE2C55),
                foregroundColor: Colors.white,
              ),
              child: const Text('Abrir Ajustes'),
            ),
          ],
        );
      },
    );
  }

  // Botón "Galería" -> selector nativo del teléfono (Android & iOS) con image_picker
  Future<void> _openGallery() async {
    if (_isPickingFromGallery || _isRecording) return;
    _isPickingFromGallery = true;

    try {
      if (Platform.isIOS) {
        final PermissionStatus photosStatus = await Permission.photos.status;
        if (photosStatus.isPermanentlyDenied || photosStatus.isRestricted) {
          await _showGalleryPermissionDialog();
          return;
        }
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (!mounted || video == null) return;

      await _navigateToPostVideo(video.path);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final String code = e.code.toLowerCase();
      final String msg = (e.message ?? '').toLowerCase();
      final bool isPermissionError = code.contains('photo_access_denied') ||
          code.contains('camera_access_denied') ||
          code.contains('permission') ||
          msg.contains('permission') ||
          msg.contains('denied');

      if (isPermissionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: const Text(
              'Permiso de galería denegado. Actívalo en los ajustes del teléfono.',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'Ajustes',
              textColor: Colors.white,
              onPressed: openAppSettings,
            ),
          ),
        );
        await _showGalleryPermissionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('No se pudo abrir la galería: ${e.message ?? e.code}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Error al acceder a la galería: $e'),
          action: SnackBarAction(
            label: 'Ajustes',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
    } finally {
      _isPickingFromGallery = false;
    }
  }

  void _openTextInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escribe tu texto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Listo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Galería de Sonidos: al tocar "Usar", guarda selectedAudioUrl y selectedAudioName y reproduce en bucle con just_audio
  Future<void> _openSoundPicker() async {
    final RoyaltyFreeSound? chosen = await showModalBottomSheet<RoyaltyFreeSound>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoundPickerSheet(initialSelectedUrl: selectedAudioUrl),
    );

    if (!mounted || chosen == null) return;

    setState(() {
      selectedAudioName = chosen.title;
      selectedAudioUrl = chosen.audioUrl;
    });
    await _playSelectedSoundInLoop(chosen.audioUrl);
  }

  // Galería de Efectos Visuales: al tocar una tarjeta o "Ninguno", actualiza selectedEffectId y aplica en Stack
  Future<void> _openEffectsGallery() async {
    final EffectsPickerResult? result =
        await showModalBottomSheet<EffectsPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EffectsGallerySheet(
        selectedEffectId: _hasActiveEffect ? selectedEffectId : null,
      ),
    );

    if (!mounted || result == null) return;
    await _applyVisualEffect(result.effect);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing && !isSimulated) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF25F4EE)),
              SizedBox(height: 14),
              Text(
                'Inicializando cámara...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_permissionDenied && !isSimulated) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E0E10),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E0E10),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _closeCamera,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: const Icon(
                    Icons.videocam_off_outlined,
                    color: Colors.white70,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Cámara en vista previa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Activa el permiso en tu teléfono o continúa con un clip de prueba para recorrer el flujo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueWithoutCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE2C55),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar sin cámara (para pruebas en web)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _requestPermissionsAndInitCamera(
                      showFeedbackOnDeny: true,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Solicitar permiso',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    _returningFromSettings = true;
                    await openAppSettings();
                  },
                  child: Text(
                    'Ir a Ajustes',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nota: La cámara solo funciona en la app instalada en tu teléfono, no en la vista previa web.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Capa 1: CameraPreview real ocupando toda la pantalla (fondo negro si _cameras está vacía)
            if (isSimulated)
              const ColoredBox(color: Colors.black)
            else if (_isInitializing ||
                _controller == null ||
                !_controller!.value.isInitialized)
              const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF25F4EE)),
                ),
              )
            else
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: _activeCameraColorFilter,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize?.height ?? 1080,
                      height: _controller!.value.previewSize?.width ?? 1920,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
              ),

            // Capa 2: Efecto visual en Stack (BlendMode.screen + opacity + VideoPlayer overlay)
            _buildCameraEffectLayer(),

            // Barra Superior
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _closeCamera,
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: _openSoundPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selectedAudioUrl != null
                              ? const Color(0xFFE91E63).withValues(alpha: 0.88)
                              : Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedAudioUrl == null) ...[
                              const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                selectedAudioName != null
                                    ? '🎵 $selectedAudioName'
                                    : 'Agregar sonido',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (selectedAudioUrl != null) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () async {
                                  await _stopCameraAudio();
                                  if (!mounted) return;
                                  setState(() {
                                    selectedAudioName = null;
                                    selectedAudioUrl = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Indicador flotante de canción seleccionada, efecto activo o grabación
            if (_isRecording || _hasActiveEffect || selectedAudioName != null)
              Positioned(
                top: 62,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedAudioName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.62),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          '🎵 $selectedAudioName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isRecording || _hasActiveEffect)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isRecording) ...[
                              const CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTimer(_recordSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ] else if (_hasActiveEffect) ...[
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF25F4EE),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedEffect?.name ?? selectedEffectId!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _applyVisualEffect(null),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // Barra Lateral Derecha
            Positioned(
              right: 16,
              top: 80,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _flipCamera,
                    child: _buildSideIcon(Icons.cameraswitch),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _openEffectsGallery,
                    child: _buildSideIcon(Icons.auto_fix_high),
                  ),
                  const SizedBox(height: 20),
                  _buildSideIcon(Icons.timer),
                  const SizedBox(height: 20),
                  _buildSideIcon(Icons.grid_view),
                  const SizedBox(height: 20),
                  _buildSideIcon(Icons.person_add_alt_1),
                  const SizedBox(height: 20),
                  _buildSideIcon(Icons.filter),
                  const SizedBox(height: 20),
                  _buildSideIcon(Icons.keyboard_arrow_down),
                ],
              ),
            ),

            // Controles Inferiores
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOption('10 min'),
                      _buildOption('60 s'),
                      _buildOption('15 s'),
                      _buildOption('FOTO', isAction: true, onTap: _openGallery),
                      _buildOption(
                        'TEXTO',
                        isAction: true,
                        onTap: _openTextInput,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Miniatura Galería
                      GestureDetector(
                        onTap: _openGallery,
                        child: Column(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27272A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Galería',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botón Grabar animado (círculo <-> cuadrado pequeño)
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: _isRecording ? 30 : 60,
                              height: _isRecording ? 30 : 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE2C55),
                                borderRadius: BorderRadius.circular(
                                  _isRecording ? 8 : 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Miniatura Efectos Visuales (abre galería de overlays)
                      GestureDetector(
                        onTap: _openEffectsGallery,
                        child: Column(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: _hasActiveEffect
                                    ? const Color(0xFF25F4EE)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFF27272A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _hasActiveEffect
                                      ? const Color(0xFF25F4EE)
                                      : Colors.white30,
                                  width: _hasActiveEffect ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: _hasActiveEffect
                                    ? const Color(0xFF25F4EE)
                                    : Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasActiveEffect ? 'Activo' : 'Efectos',
                              style: TextStyle(
                                color: _hasActiveEffect
                                    ? const Color(0xFF25F4EE)
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: _hasActiveEffect
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'CÁMARA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openGallery,
                        child: const Text(
                          'CREAR',
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }

  Widget _buildOption(
    String text, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    final bool isSelected = _selectedTime == text;

    return GestureDetector(
      onTap: () {
        if (isAction && onTap != null) {
          onTap();
        } else {
          setState(() => _selectedTime = text);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected && !isAction
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: (isSelected && !isAction) || isAction
                ? Colors.white
                : Colors.white54,
            fontWeight: (isSelected && !isAction) || isAction
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}