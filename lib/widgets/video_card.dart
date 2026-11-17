import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';
import '../services/video_download_service.dart';
import '../theme/app_colors.dart';
import 'comments_bottom_sheet.dart';

class VideoCard extends StatefulWidget {
  final String? videoId;
  final String? postId;
  final String videoUrl;
  final String username;
  final String caption;
  final int likes;
  final int comments;
  final String avatarUrl;
  final String uid;
  final List<String> likedBy;
  final String? audioName;
  final String? effectUsed;
  final String? effectVideoUrl;
  final bool isActive;

  const VideoCard({
    super.key,
    this.videoId,
    this.postId,
    required this.videoUrl,
    this.username = 'usuario',
    this.caption = '',
    this.likes = 0,
    this.comments = 0,
    this.avatarUrl = '',
    this.uid = '',
    this.likedBy = const [],
    this.audioName,
    this.effectUsed,
    this.effectVideoUrl,
    this.isActive = true,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  VideoPlayerController? _effectController;
  final VideoDownloadService _downloadService = VideoDownloadService();

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isEffectInitialized = false;
  bool _isPausedByUser = false;
  bool _isVisible = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _topBannerMessage;
  bool _topBannerSuccess = false;
  double _fireScale = 1.0;

  String get _resolvedVideoId => widget.videoId ?? widget.postId ?? '';

  void _onControllerUpdated() {
    if (!mounted) return;
    final VideoPlayerController? controller = _controller;
    if (controller != null && controller.value.hasError && !_hasError) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _initVideoController(String url) async {
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
    }

    if (url.trim().isEmpty) {
      if (mounted) {
        setState(() => _hasError = true);
      }
      return;
    }

    try {
      final bool isRemote = url.startsWith('http');
      final VideoPlayerController controller = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(url))
          : VideoPlayerController.file(File(url));

      _controller = controller;
      controller.addListener(_onControllerUpdated);

      await controller.initialize();
      if (!mounted) return;

      await controller.setLooping(true);
      await controller.setVolume(0.0);

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      if (_isVisible && widget.isActive && !_isPausedByUser) {
        await controller.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _hasError = true;
      });
    }
  }

  Future<void> _retryVideo() async {
    final VideoPlayerController? old = _controller;
    _controller = null;
    if (old != null) {
      old.removeListener(_onControllerUpdated);
      await old.dispose();
    }
    await _initVideoController(widget.videoUrl);
  }

  @override
  void initState() {
    super.initState();
    _initVideoController(widget.videoUrl);

    if (widget.effectVideoUrl != null && widget.effectVideoUrl!.isNotEmpty) {
      _effectController = VideoPlayerController.networkUrl(
        Uri.parse(widget.effectVideoUrl!),
      );
      _effectController!.initialize().then((_) {
        if (!mounted) return;
        _effectController!
          ..setLooping(true)
          ..setVolume(0.0);
        setState(() => _isEffectInitialized = true);
        if (_isVisible && widget.isActive && !_isPausedByUser) {
          _effectController!.play();
        }
      }).catchError((_) {});
    }
  }

  @override
  void didUpdateWidget(covariant VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      final VideoPlayerController? old = _controller;
      _controller = null;
      if (old != null) {
        old.removeListener(_onControllerUpdated);
        old.dispose();
      }
      _initVideoController(widget.videoUrl);
      return;
    }
    final VideoPlayerController? controller = _controller;
    if (!_isInitialized || controller == null) return;
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && _isVisible && !_isPausedByUser) {
        controller.play();
        if (_isEffectInitialized) _effectController?.play();
      } else if (!widget.isActive && controller.value.isPlaying) {
        controller.pause();
        _effectController?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdated);
    _effectController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo visibilityInfo) {
    final bool visible = visibilityInfo.visibleFraction > 0.5;
    _isVisible = visible;
    final VideoPlayerController? controller = _controller;
    if (!mounted || !_isInitialized || controller == null) return;

    if (visible && widget.isActive && !_isPausedByUser) {
      if (!controller.value.isPlaying) {
        controller.play();
        if (_isEffectInitialized) _effectController?.play();
      }
    } else {
      if (controller.value.isPlaying) {
        controller.pause();
        _effectController?.pause();
      }
    }
  }

  void _togglePlayPause() {
    final VideoPlayerController? controller = _controller;
    if (!_isInitialized || _hasError || controller == null) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _effectController?.pause();
        _isPausedByUser = true;
      } else {
        controller.play();
        if (_isEffectInitialized) _effectController?.play();
        _isPausedByUser = false;
      }
    });
  }

  void _triggerFireAnimation() {
    setState(() => _fireScale = 1.32);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() => _fireScale = 1.0);
      }
    });
  }

  void _handleFireLikeTap(VideoProvider videoProvider) {
    _triggerFireAnimation();
    videoProvider.toggleLike(_resolvedVideoId);
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  void _openCommentsSheet() {
    if (_resolvedVideoId.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(videoId: _resolvedVideoId),
    );
  }

  Future<void> _handleDownload() async {
    if (_isDownloading || widget.videoUrl.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _topBannerMessage = 'Descargando video...';
      _topBannerSuccess = false;
    });

    try {
      await _downloadService.downloadAndSaveToGallery(
        videoUrl: widget.videoUrl,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _topBannerMessage = 'Video descargado con éxito';
        _topBannerSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Video guardado en tu galería!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _topBannerSuccess) {
          setState(() => _topBannerMessage = null);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _topBannerMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo descargar el video'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoProvider>();
    final userProvider = context.watch<UserProvider>();
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwnPost = currentUid != null && widget.uid == currentUid;
    final bool isLiked = currentUid != null
        ? widget.likedBy.contains(currentUid)
        : videoProvider.isLiked(_resolvedVideoId);

    final bool hasEffect =
        widget.effectUsed != null &&
        widget.effectUsed!.isNotEmpty &&
        widget.effectUsed != 'Ninguno';

    return VisibilityDetector(
      key: Key('video_${_resolvedVideoId.isNotEmpty ? _resolvedVideoId : widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Reproductor de Video con VideoPlayerController
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayPause,
            child: Container(
              color: const Color(0xFF1F1F23),
              child: _hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFA1A1AA),
                              size: 44,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Error al cargar el video. Intenta de nuevo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFE4E4E7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _retryVideo,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFE2C55),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : (!_isInitialized || _controller == null)
                      ? Container(
                          color: const Color(0xFF1F1F23),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.movie_creation_outlined,
                                  color: Color(0xFF52525B),
                                  size: 44,
                                ),
                                SizedBox(height: 14),
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF5722),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: _controller!.value.size.width > 0
                                      ? _controller!.value.size.width
                                      : 1080,
                                  height: _controller!.value.size.height > 0
                                      ? _controller!.value.size.height
                                      : 1920,
                                  child: AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio > 0
                                        ? _controller!.value.aspectRatio
                                        : 9 / 16,
                                    child: VideoPlayer(_controller!),
                                  ),
                                ),
                              ),
                            ),
                            if (hasEffect)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.35,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        backgroundBlendMode: BlendMode.screen,
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
                            if (_isEffectInitialized && _effectController != null)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.42,
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
                                          aspectRatio:
                                              _effectController!.value.aspectRatio > 0
                                                  ? _effectController!.value.aspectRatio
                                                  : 9 / 16,
                                          child: VideoPlayer(_effectController!),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (_isPausedByUser)
                              Center(
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 92,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                          ],
                        ),
            ),
          ),

          // 2. Scrim superior sutil y gradiente semi-transparente inferior en Stack para legibilidad
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.42),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 240,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.48),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Banner de descarga
          if (_topBannerMessage != null)
            Positioned(
              top: 64,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_topBannerSuccess) ...[
                        const Icon(
                          Icons.arrow_downward_rounded,
                          color: AppColors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            value: _downloadProgress > 0
                                ? _downloadProgress
                                : null,
                            strokeWidth: 2.2,
                            color: AppColors.orange,
                          ),
                        ),
                      ] else
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF34D399),
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _topBannerMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Barra lateral derecha: Avatar del creador + Fuego (Likes) + Comentarios + Descarga
          Positioned(
            right: 12,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar (avatarUrl del creador) + Seguir
                      Builder(
                        builder: (context) {
                          final String resolvedAvatar = isOwnPost &&
                                  userProvider.avatarUrl.isNotEmpty
                              ? userProvider.avatarUrl
                              : widget.avatarUrl;
                          final bool isFollowing =
                              videoProvider.isFollowing(widget.uid);

                          return GestureDetector(
                            onTap: isOwnPost
                                ? null
                                : () => videoProvider.toggleFollow(widget.uid),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  margin: EdgeInsets.only(
                                    bottom: isOwnPost ? 0 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF27272A),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    image: resolvedAvatar.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(resolvedAvatar),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: resolvedAvatar.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                if (!isOwnPost)
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isFollowing
                                          ? null
                                          : AppColors.brandGradient,
                                      color: isFollowing ? Colors.white : null,
                                    ),
                                    child: Icon(
                                      isFollowing ? Icons.check : Icons.add,
                                      color: isFollowing
                                          ? Colors.black
                                          : Colors.white,
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Botón de Fuego (Likes dinámicos desde Firestore con animación de escala al tocar)
                      GestureDetector(
                        onTap: () => _handleFireLikeTap(videoProvider),
                        child: Column(
                          children: [
                            AnimatedScale(
                              scale: _fireScale,
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                color: isLiked ? AppColors.orange : Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatCount(widget.likes),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón de Comentarios (valor real desde Firestore)
                      GestureDetector(
                        onTap: _openCommentsSheet,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _formatCount(widget.comments),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Descargar
                      GestureDetector(
                        onTap: _isDownloading ? null : _handleDownload,
                        child: Column(
                          children: [
                            if (_isDownloading)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  value: _downloadProgress > 0
                                      ? _downloadProgress
                                      : null,
                                  strokeWidth: 2.8,
                                  color: AppColors.orange,
                                  backgroundColor: Colors.white24,
                                ),
                              )
                            else
                              const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              _isDownloading ? 'Descargando' : 'Descargar',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Parte inferior izquierda: @username, caption y audio
          Positioned(
            left: 14,
            right: 92,
            bottom: 18,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${widget.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.caption.isNotEmpty)
                    Text(
                      widget.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (widget.audioName != null &&
                                  widget.audioName!.isNotEmpty)
                              ? widget.audioName!
                              : 'Sonido original · Viroklipz',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}