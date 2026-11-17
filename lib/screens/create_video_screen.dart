import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../services/r2_upload_service.dart';
import '../services/supabase_video_service.dart';

class CreateVideoScreen extends StatefulWidget {
  final File? initialVideoFile;
  final VoidCallback? onVideoPublished;

  const CreateVideoScreen({
    super.key,
    this.initialVideoFile,
    this.onVideoPublished,
  });

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final _picker = ImagePicker();
  final _r2Service = R2UploadService();
  final _videoService = SupabaseVideoService();

  final _descriptionController = TextEditingController();
  final _audioController = TextEditingController();

  File? _selectedVideo;
  VideoPlayerController? _previewController;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoFile != null) {
      _loadPreviewFile(widget.initialVideoFile!);
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    _descriptionController.dispose();
    _audioController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviewFile(File videoFile) async {
    final oldController = _previewController;
    final nextController = VideoPlayerController.file(videoFile);
    await nextController.initialize();
    await nextController.setLooping(true);
    await nextController.play();
    await oldController?.dispose();

    if (!mounted) {
      await nextController.dispose();
      return;
    }

    setState(() {
      _selectedVideo = videoFile;
      _previewController = nextController;
      _errorMessage = null;
    });
  }

  Future<void> _pickVideoFromGallery() async {
    if (_isUploading) return;
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (file == null) return;
      await _loadPreviewFile(File(file.path));
    } catch (e) {
      setState(() => _errorMessage = 'No se pudo cargar el video: $e');
    }
  }

  Future<void> _publishVideo() async {
    if (_selectedVideo == null || _isUploading) return;

    final user = Supabase.instance.client.auth.currentUser;
    final String caption = _descriptionController.text.trim();
    final String audioName = _audioController.text.trim();

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      if (user != null) {
        final String publicVideoUrl = await _r2Service.uploadVideo(
          videoFile: _selectedVideo!,
          userId: user.id,
          onProgress: (progress) {
            if (mounted) {
              setState(() => _uploadProgress = progress);
            }
          },
        );

        await _videoService.createVideoRecord(
          videoUrl: publicVideoUrl,
          description: caption,
          audioName: audioName,
        );

        if (mounted) {
          context.read<VideoProvider>().uploadVideo(publicVideoUrl, caption);
        }
      } else {
        // Modo MVP local: publica directo en VideoProvider con la ruta del archivo
        context.read<VideoProvider>().uploadVideo(_selectedVideo!.path, caption);
      }

      if (!mounted) return;
      widget.onVideoPublished?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasReadyPreview =
        _previewController != null && _previewController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Capa base 100%: Video en bucle o invitación de galería
          Positioned.fill(
            child: hasReadyPreview
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _previewController!.value.size.width,
                      height: _previewController!.value.size.height,
                      child: VideoPlayer(_previewController!),
                    ),
                  )
                : GestureDetector(
                    onTap: _pickVideoFromGallery,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: const Color(0xFF09090B),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 56,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Toca para subir un video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Scrim superior e inferior para garantizar legibilidad de la UI
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.22, 0.52, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Arriba a la izquierda: Botón X (Cerrar) y botón opcional para cambiar video
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _isUploading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                    if (_selectedVideo != null && !_isUploading)
                      TextButton.icon(
                        onPressed: _pickVideoFromGallery,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Cambiar',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.45),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Abajo (estilo TikTok): Inputs transparentes + botón Publicar vibrante
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _descriptionController,
                      enabled: !_isUploading,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      cursorColor: const Color(0xFFFE2C55),
                      decoration: const InputDecoration(
                        hintText: 'Escribe una descripción y #hashtags...',
                        hintStyle: TextStyle(color: Colors.white60, fontSize: 15),
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _audioController,
                      enabled: !_isUploading,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: const Color(0xFFFE2C55),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.music_note_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 28, minHeight: 28),
                        hintText: 'Nombre del audio (opcional)',
                        hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),
                    if (_isUploading) ...[
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        color: const Color(0xFFFE2C55),
                        backgroundColor: Colors.white24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Publicando... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFFF4D6D), fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_selectedVideo == null || _isUploading)
                            ? null
                            : _publishVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE2C55),
                          disabledBackgroundColor:
                              const Color(0xFFFE2C55).withValues(alpha: 0.35),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white54,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Publicar',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}