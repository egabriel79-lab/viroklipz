import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/video_card.dart';

class VideoDetailScreen extends StatelessWidget {
  final String videoId;

  const VideoDetailScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('videos')
                .doc(videoId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                );
              }

              final doc = snapshot.data;
              if (doc == null || !doc.exists) {
                return const Center(
                  child: Text(
                    'Este video ya no está disponible.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                );
              }

              final data = doc.data() ?? <String, dynamic>{};
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
                audioName: (data['audioName'] ?? '').toString(),
                effectUsed: (data['effectUsed'] ?? '').toString(),
                effectVideoUrl: (data['effectVideoUrl'] ?? '').toString(),
                isActive: true,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}