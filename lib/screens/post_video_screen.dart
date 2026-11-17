import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class PostVideoScreen extends StatefulWidget {
  final String videoPath;
  final String? audioName;
  final String? audioUrl;
  final String? effectUsed;
  final String? effectVideoUrl;

  const PostVideoScreen({
    super.key,
    required this.videoPath,
    this.audioName,
    this.audioUrl,
    this.effectUsed,
    this.effectVideoUrl,
  });

  @override
  State<PostVideoScreen> createState() => _PostVideoScreenState();
}

class _PostVideoScreenState extends State<PostVideoScreen> {
  final TextEditingController _captionController = TextEditingController();
  late final TextEditingController _audioController;
  late final VideoPlayerController _videoController;
  VideoPlayerController? _effectController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isVideoReady = false;
  bool _isEffectReady = false;
  bool _isUploading = false;
  bool _canPublish = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioController = TextEditingController(text: widget.audioName ?? '');
    _captionController.addListener(_handleCaptionChanged);

    final bool isRemote = widget.videoPath.startsWith('http');
    _videoController = isRemote
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        : VideoPlayerController.file(File(widget.videoPath));

    _videoController
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isVideoReady = true);
        _videoController.play();
      });

    if (widget.effectVideoUrl != null && widget.effectVideoUrl!.isNotEmpty) {
      _effectController = VideoPlayerController.networkUrl(
        Uri.parse(widget.effectVideoUrl!),
      )
        ..setLooping(true)
        ..setVolume(0.0)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _isEffectReady = true);
          _effectController?.play();
        });
    }

    if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      _startBackgroundAudio(widget.audioUrl!);
    }
  }

  void _handleCaptionChanged() {
    final bool hasText = _captionController.text.trim().isNotEmpty;
    if (hasText != _canPublish && mounted) {
      setState(() => _canPublish = hasText);
    }
  }

  List<String> _extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#([\p{L}\p{N}_]+)', unicode: true);
    final Set<String> extracted = <String>{};
    for (final Match match in hashtagRegex.allMatches(text)) {
      final String? rawTag = match.group(1)?.trim().toLowerCase();
      if (rawTag != null && rawTag.isNotEmpty) {
        extracted.add(rawTag);
      }
    }
    return extracted.toList();
  }

  Future<void> _startBackgroundAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _videoController.setVolume(0.25);
      await _audioPlayer.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _captionController.removeListener(_handleCaptionChanged);
    _audioPlayer.dispose();
    _effectController?.dispose();
    _videoController.dispose();
    _captionController.dispose();
    _audioController.dispose();
    super.dispose();
  }

  void _togglePreviewPlayback() {
    if (!_isVideoReady) return;
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _effectController?.pause();
        _audioPlayer.pause();
      } else {
        _videoController.play();
        _effectController?.play();
        if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
          _audioPlayer.play();
        }
      }
    });
  }

  Future<void> _publishVideo() async {
    final String caption = _captionController.text.trim();
    if (_isUploading || caption.isEmpty) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Debes iniciar sesión para publicar un video.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      String username = (authProvider.userProfile?['username'] ??
              authProvider.currentUser?.username ??
              user.displayName ??
              user.email?.split('@').first ??
              'usuario')
          .toString();
      String avatarUrl = (authProvider.userProfile?['avatarUrl'] ??
              authProvider.currentUser?.avatarUrl ??
              user.photoURL ??
              '')
          .toString();

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (data != null) {
          username = (data['username'] ?? username).toString();
          avatarUrl = (data['avatarUrl'] ?? avatarUrl).toString();
        }
      } catch (_) {}

      // Paso A (Storage): Si viene de prueba web (http), reutilizar URL; si es archivo local, subir como .mp4
      late final String downloadUrl;
      if (widget.videoPath.startsWith('http')) {
        setState(() => _uploadProgress = 1.0);
        downloadUrl = widget.videoPath;
      } else {
        File file = File(widget.videoPath);
        if (!file.path.toLowerCase().endsWith('.mp4')) {
          final Directory tempDir = await getTemporaryDirectory();
          final String mp4Path =
              '${tempDir.path}/viroklipz_${DateTime.now().millisecondsSinceEpoch}.mp4';
          file = await file.copy(mp4Path);
        }

        final String uniqueId = const Uuid().v4();
        final Reference storageRef =
            FirebaseStorage.instance.ref('videos/$uniqueId.mp4');
        final metadata = SettableMetadata(contentType: 'video/mp4');
        final UploadTask uploadTask = storageRef.putFile(file, metadata);

        final sub = uploadTask.snapshotEvents.listen((TaskSnapshot snap) {
          if (mounted && snap.totalBytes > 0) {
            setState(() {
              _uploadProgress =
                  (snap.bytesTransferred / snap.totalBytes).clamp(0.0, 1.0);
            });
          }
        });

        final TaskSnapshot completedSnapshot = await uploadTask;
        await sub.cancel();
        downloadUrl = await completedSnapshot.ref.getDownloadURL();
      }

      // Paso B (Hashtags + Firestore): Extraer hashtags (#palabra -> "palabra") y guardar en "videos"
      final List<String> hashtags = _extractHashtags(caption);
      final String audioName = _audioController.text.trim();

      await FirebaseFirestore.instance.collection('videos').add({
        'videoUrl': downloadUrl,
        'caption': caption,
        'hashtags': hashtags,
        'audioName': audioName,
        'audioUrl': widget.audioUrl ?? '',
        'effectUsed': widget.effectUsed ?? 'Ninguno',
        'effectVideoUrl': widget.effectVideoUrl ?? '',
        'uid': user.uid,
        'authorId': user.uid,
        'username': username,
        'avatarUrl': avatarUrl,
        'likedBy': <String>[],
        'likes': 0,
        'likesCount': 0,
        'comments': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      await _videoController.pause();
      await _effectController?.pause();
      await _audioPlayer.stop();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text('¡Video publicado en Viroklipz!'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo subir el video: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Error al publicar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEffect =
        widget.effectUsed != null &&
        widget.effectUsed!.isNotEmpty &&
        widget.effectUsed != 'Ninguno';
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    final String displayAuthorName = userProvider.displayName.isNotEmpty
        ? userProvider.displayName
        : (userProvider.username.isNotEmpty
            ? userProvider.username
            : (authProvider.currentUser?.username ??
                firebaseUser?.displayName ??
                firebaseUser?.email?.split('@').first ??
                'Eloy'));
    final String authorAvatarUrl = userProvider.avatarUrl.isNotEmpty
        ? userProvider.avatarUrl
        : (authProvider.currentUser?.avatarUrl ?? firebaseUser?.photoURL ?? '');
    final bool isPublishDisabled = _isUploading || !_canPublish;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Publicar clip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Previsualización con Stack: VideoPlayer base + efecto overlay
                    GestureDetector(
                      onTap: _togglePreviewPlayback,
                      child: Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: !_isVideoReady
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.orange,
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController.value.size.width > 0
                                          ? _videoController.value.size.width
                                          : 1080,
                                      height: _videoController.value.size.height > 0
                                          ? _videoController.value.size.height
                                          : 1920,
                                      child: AspectRatio(
                                        aspectRatio:
                                            _videoController.value.aspectRatio > 0
                                                ? _videoController.value.aspectRatio
                                                : 9 / 16,
                                        child: VideoPlayer(_videoController),
                                      ),
                                    ),
                                  ),
                                  if (hasEffect)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: Opacity(
                                          opacity: 0.42,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              backgroundBlendMode:
                                                  BlendMode.screen,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0x9925F4EE),
                                                  Color(0x55E91E63),
                                                  Color(0x88FF5722),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_isEffectReady && _effectController != null)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: Opacity(
                                          opacity: 0.42,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
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
                                      ),
                                    ),
                                  if (!_videoController.value.isPlaying)
                                    Center(
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        size: 72,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 2. Nombre del usuario
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF27272A),
                          backgroundImage: authorAvatarUrl.isNotEmpty
                              ? NetworkImage(authorAvatarUrl)
                              : null,
                          child: authorAvatarUrl.isEmpty
                              ? Text(
                                  displayAuthorName.isNotEmpty
                                      ? displayAuthorName[0].toUpperCase()
                                      : 'E',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            displayAuthorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 3. Campo de descripción y hashtags (justo debajo del nombre y antes del audio)
                    TextField(
                      controller: _captionController,
                      enabled: !_isUploading,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      cursorColor: AppColors.orange,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe tu video y agrega hashtags (ej. #humor #baile #musica)',
                        hintStyle: TextStyle(color: Color(0xFF71717A)),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 10,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white38,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. Campo de audio opcional (y efecto seleccionado si aplica)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note_rounded,
                                color: AppColors.magenta,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _audioController,
                                  enabled: !_isUploading,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  cursorColor: AppColors.orange,
                                  decoration: const InputDecoration(
                                    hintText: 'Nombre del audio (opcional)',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF71717A),
                                      fontSize: 13.5,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasEffect) ...[
                            const Divider(color: Colors.white10, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF25F4EE),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Efecto: ${widget.effectUsed!}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (_isUploading) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: _uploadProgress > 0 ? _uploadProgress : null,
                                color: AppColors.orange,
                                strokeWidth: 2.8,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _uploadProgress > 0
                                    ? 'Subiendo video... ${(_uploadProgress * 100).toStringAsFixed(0)}%'
                                    : 'Subiendo video...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF4D6D),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 5. Botón grande "Publicar" (deshabilitado si la descripción está vacía o está subiendo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isPublishDisabled ? 0.45 : 1.0,
                child: Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isPublishDisabled
                        ? const <BoxShadow>[]
                        : [
                            BoxShadow(
                              color: AppColors.orange.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: isPublishDisabled ? null : _publishVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.white70,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Subiendo video...',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}