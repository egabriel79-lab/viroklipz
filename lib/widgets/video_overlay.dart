import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_post.dart';
import '../providers/user_provider.dart';
import '../providers/video_provider.dart';
import '../services/video_download_service.dart';
import '../theme/app_colors.dart';
import 'comments_bottom_sheet.dart';

class VideoOverlay extends StatefulWidget {
  final VideoPost post;

  const VideoOverlay({super.key, required this.post});

  @override
  State<VideoOverlay> createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<VideoOverlay> {
  final VideoDownloadService _downloadService = VideoDownloadService();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _topBannerMessage;
  bool _topBannerSuccess = false;
  double _fireScale = 1.0;

  void _triggerFireAnimation() {
    setState(() => _fireScale = 1.32);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() => _fireScale = 1.0);
      }
    });
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  void _openCommentsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(videoId: widget.post.id),
    );
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _topBannerMessage = 'Descargando video...';
      _topBannerSuccess = false;
    });

    try {
      await _downloadService.downloadAndSaveToGallery(
        videoUrl: widget.post.videoUrl,
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
    final post = widget.post;
    final videoProvider = context.watch<VideoProvider>();
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwnPost = post.author.id == videoProvider.currentUser.id ||
        (currentUid != null && post.author.id == currentUid);

    return Stack(
      children: [
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

        // Overlay superior de progreso / éxito de descarga
        if (_topBannerMessage != null)
          Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                          value: _downloadProgress > 0 ? _downloadProgress : null,
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

        Positioned(
          right: 12,
          bottom: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('videos')
                      .doc(post.id)
                      .snapshots(),
                  builder: (context, videoSnapshot) {
                    final videoData = videoSnapshot.data?.data();
                    final List<String> likedBy = List<String>.from(
                      videoData?['likedBy'] ?? post.likedBy,
                    );
                    final bool isLiked = currentUid != null
                        ? (videoData != null
                            ? likedBy.contains(currentUid)
                            : videoProvider.isLiked(post.id))
                        : videoProvider.isLiked(post.id);
                    final int likesCount =
                        (videoData?['likes'] as num?)?.toInt() ??
                            (videoData?['likesCount'] as num?)?.toInt() ??
                            post.likes;
                    final int commentsCount =
                        (videoData?['comments'] as num?)?.toInt() ??
                            (videoData?['commentsCount'] as num?)?.toInt() ??
                            post.comments;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar del autor + botón Seguir en tiempo real (users/{miUid}/following/{suUid})
                        Builder(
                          builder: (context) {
                            final userProvider = context.watch<UserProvider>();

                            Widget buildAvatarCircle(
                              String resolvedAvatarUrl, {
                              required bool isFollowing,
                            }) {
                              return Stack(
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
                                      image: resolvedAvatarUrl.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                resolvedAvatarUrl,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: resolvedAvatarUrl.isEmpty
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
                                        color:
                                            isFollowing ? Colors.white : null,
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
                              );
                            }

                            if (isOwnPost) {
                              final String myAvatar =
                                  userProvider.avatarUrl.isNotEmpty
                                      ? userProvider.avatarUrl
                                      : post.author.avatarUrl;
                              return buildAvatarCircle(
                                myAvatar,
                                isFollowing: false,
                              );
                            }

                            return GestureDetector(
                              onTap: () =>
                                  videoProvider.toggleFollow(post.author.id),
                              child: StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(post.author.id)
                                    .snapshots(),
                                builder: (context, authorSnapshot) {
                                  final String firestoreAvatar =
                                      (authorSnapshot.data
                                                  ?.data()?['avatarUrl'] ??
                                              '')
                                          .toString();
                                  final String effectiveAvatar =
                                      firestoreAvatar.isNotEmpty
                                          ? firestoreAvatar
                                          : post.author.avatarUrl;

                                  if (currentUid == null) {
                                    return buildAvatarCircle(
                                      effectiveAvatar,
                                      isFollowing: videoProvider
                                          .isFollowing(post.author.id),
                                    );
                                  }

                                  return StreamBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(currentUid)
                                        .collection('following')
                                        .doc(post.author.id)
                                        .snapshots(),
                                    builder: (context, followSnap) {
                                      final bool isFollowing = followSnap
                                              .hasData
                                          ? followSnap.data!.exists
                                          : videoProvider
                                              .isFollowing(post.author.id);
                                      return buildAvatarCircle(
                                        effectiveAvatar,
                                        isFollowing: isFollowing,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Botón de Llama (Blanco a Naranja en tiempo real con animación de escala al tocar)
                        GestureDetector(
                          onTap: () {
                            _triggerFireAnimation();
                            videoProvider.toggleLike(post.id);
                          },
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
                                _formatCount(likesCount),
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

                        // Botón de Comentarios (Abre BottomSheet + contador en tiempo real)
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
                                _formatCount(commentsCount),
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

                        // Botón Descargar a Galería
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
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
                  '@${post.author.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.caption,
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
                        (post.audioName != null && post.audioName!.isNotEmpty)
                            ? post.audioName!
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
    );
  }
}