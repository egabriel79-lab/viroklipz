import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/video_card.dart';
import 'camera_screen.dart';

class FriendsFeedScreen extends StatefulWidget {
  final bool isFeedVisible;
  final VoidCallback? onOpenCamera;

  const FriendsFeedScreen({
    super.key,
    this.isFeedVisible = true,
    this.onOpenCamera,
  });

  @override
  State<FriendsFeedScreen> createState() => _FriendsFeedScreenState();
}

class _FriendsFeedScreenState extends State<FriendsFeedScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _openCameraFallback() {
    if (widget.onOpenCamera != null) {
      widget.onOpenCamera!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CameraScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoProvider>();
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('videos')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                );
              }

              final allDocs = snapshot.data?.docs ?? [];
              final communityDocs = allDocs.where((doc) {
                final data = doc.data();
                final String uid =
                    (data['uid'] ?? data['authorId'] ?? '').toString();
                return videoProvider.followingIds.contains(uid) ||
                    (currentUid != null && uid == currentUid);
              }).toList();

              if (allDocs.isEmpty || communityDocs.isEmpty) {
                final bool noVideosAtAll = allDocs.isEmpty;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 52,
                          color: AppColors.orange,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          noVideosAtAll
                              ? 'Aún no hay videos. ¡Sé el primero en subir uno!'
                              : 'Aún no hay videos en Comunidad',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noVideosAtAll
                              ? 'Graba o selecciona un clip desde tu cámara para iniciar el feed.'
                              : 'Sigue a creadores en "Radar" o sube tu propio video para verlo aquí.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _openCameraFallback,
                            icon: const Icon(Icons.videocam_rounded, size: 18),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 11,
                              ),
                            ),
                            label: const Text('Subir video'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final int safePage =
                  _currentPage.clamp(0, communityDocs.length - 1);

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: communityDocs.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final doc = communityDocs[index];
                  final data = doc.data();

                  final String videoUrl = (data['videoUrl'] ?? '').toString();
                  final String username =
                      (data['username'] ?? 'usuario').toString();
                  final String caption = (data['caption'] ?? '').toString();
                  final int likes =
                      ((data['likes'] ?? data['likesCount'] ?? 0) as num)
                          .toInt();
                  final int comments =
                      ((data['comments'] ?? data['commentsCount'] ?? 0) as num)
                          .toInt();
                  final String avatarUrl = (data['avatarUrl'] ?? '').toString();
                  final String uid =
                      (data['uid'] ?? data['authorId'] ?? '').toString();
                  final List<String> likedBy = List<String>.from(
                    data['likedBy'] ?? const <String>[],
                  );
                  final String audioName = (data['audioName'] ?? '').toString();
                  final String effectUsed =
                      (data['effectUsed'] ?? '').toString();
                  final String effectVideoUrl =
                      (data['effectVideoUrl'] ?? '').toString();

                  final isActive = widget.isFeedVisible && safePage == index;

                  return VideoCard(
                    key: ValueKey(doc.id),
                    videoId: doc.id,
                    videoUrl: videoUrl,
                    username: username,
                    caption: caption,
                    likes: likes,
                    comments: comments,
                    avatarUrl: avatarUrl,
                    uid: uid,
                    likedBy: likedBy,
                    audioName: audioName,
                    effectUsed: effectUsed,
                    effectVideoUrl: effectVideoUrl,
                    isActive: isActive,
                  );
                },
              );
            },
          ),

          // Barra Superior de Comunidad
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 28),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Comunidad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.search, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}