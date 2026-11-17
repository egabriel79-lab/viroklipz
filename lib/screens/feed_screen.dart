import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/video_card.dart';
import 'camera_screen.dart';

class FeedScreen extends StatefulWidget {
  final bool isFeedVisible;
  final VoidCallback? onOpenCamera;

  const FeedScreen({
    super.key,
    this.isFeedVisible = true,
    this.onOpenCamera,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final PageController _pageController;

  int _currentPage = 0;
  int _selectedTopTab = 1; // 0 = Círculo, 1 = Radar (Inicio)

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _switchTopTab(int tabIndex) {
    if (_selectedTopTab == tabIndex) return;
    setState(() {
      _selectedTopTab = tabIndex;
      _currentPage = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
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

    return Stack(
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

            if (snapshot.hasError) {
              return _FeedEmptyState(
                isCircleTab: false,
                onExploreRadar: () => _switchTopTab(1),
                onOpenCamera: _openCameraFallback,
                errorText: 'No se pudieron cargar los videos de Firestore.',
              );
            }

            final allDocs = snapshot.data?.docs ?? [];

            if (allDocs.isEmpty) {
              return _FeedEmptyState(
                isCircleTab: false,
                onExploreRadar: () => _switchTopTab(1),
                onOpenCamera: _openCameraFallback,
              );
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                _selectedTopTab == 0
                    ? allDocs.where((doc) {
                        final data = doc.data();
                        final String uid =
                            (data['uid'] ?? data['authorId'] ?? '').toString();
                        return videoProvider.followingIds.contains(uid) ||
                            (currentUid != null && uid == currentUid);
                      }).toList()
                    : allDocs;

            if (docs.isEmpty) {
              return _FeedEmptyState(
                isCircleTab: _selectedTopTab == 0,
                onExploreRadar: () => _switchTopTab(1),
                onOpenCamera: _openCameraFallback,
              );
            }

            final int safePage = _currentPage.clamp(0, docs.length - 1);

            return PageView.builder(
              key: ValueKey(_selectedTopTab),
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: docs.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();

                final String videoUrl = (data['videoUrl'] ?? '').toString();
                final String username =
                    (data['username'] ?? 'usuario').toString();
                final String caption = (data['caption'] ?? '').toString();
                final int likes =
                    ((data['likes'] ?? data['likesCount'] ?? 0) as num).toInt();
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
                final String effectUsed = (data['effectUsed'] ?? '').toString();
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

        // Tabs Superiores: Círculo | Radar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TopTabButton(
                  label: 'Círculo',
                  isSelected: _selectedTopTab == 0,
                  onTap: () => _switchTopTab(0),
                ),
                const SizedBox(width: 24),
                _TopTabButton(
                  label: 'Radar',
                  isSelected: _selectedTopTab == 1,
                  onTap: () => _switchTopTab(1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  final bool isCircleTab;
  final VoidCallback onExploreRadar;
  final VoidCallback onOpenCamera;
  final String? errorText;

  const _FeedEmptyState({
    required this.isCircleTab,
    required this.onExploreRadar,
    required this.onOpenCamera,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_outlined,
              size: 52,
              color: AppColors.orange,
            ),
            const SizedBox(height: 14),
            Text(
              errorText ??
                  (isCircleTab
                      ? 'Aún no hay clips en tu Círculo'
                      : 'Aún no hay videos. ¡Sé el primero en subir uno!'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCircleTab
                  ? 'Sigue a creadores en Radar para ver sus videos aquí.'
                  : 'Graba o selecciona un video desde tu cámara y compártelo en Viroklipz.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton.icon(
                onPressed: isCircleTab ? onExploreRadar : onOpenCamera,
                icon: Icon(
                  isCircleTab ? Icons.explore_outlined : Icons.videocam_rounded,
                  size: 18,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                label: Text(isCircleTab ? 'Ir a Radar' : 'Subir primer video'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}