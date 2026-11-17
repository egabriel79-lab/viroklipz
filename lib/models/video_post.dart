import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

class VideoPost {
  final String id;
  final AppUser author;
  final String videoUrl;
  final String? imageUrl;
  final String? audioName;
  final String? audioUrl;
  final String? effectUsed;
  final String? effectVideoUrl;
  final String caption;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final List<String> likedBy;

  VideoPost({
    required this.id,
    required this.author,
    required this.videoUrl,
    this.imageUrl,
    this.audioName,
    this.audioUrl,
    this.effectUsed,
    this.effectVideoUrl,
    required this.caption,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
  });

  factory VideoPost.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final String rawAudioName = (data['audioName'] ?? '').toString().trim();
    final String rawAudioUrl = (data['audioUrl'] ?? '').toString().trim();
    final String rawEffectUsed = (data['effectUsed'] ?? '').toString().trim();
    final String rawEffectUrl =
        (data['effectVideoUrl'] ?? '').toString().trim();
    final rawLikes = data['likes'] ?? data['likesCount'] ?? 0;
    final rawComments = data['comments'] ?? data['commentsCount'] ?? 0;
    final String resolvedUid =
        (data['uid'] ?? data['authorId'] ?? '').toString();

    return VideoPost(
      id: doc.id,
      author: AppUser(
        id: resolvedUid,
        username: (data['username'] ?? 'usuario').toString(),
        avatarUrl: (data['avatarUrl'] ?? '').toString(),
      ),
      videoUrl: (data['videoUrl'] ?? '').toString(),
      audioName: rawAudioName.isEmpty ? null : rawAudioName,
      audioUrl: rawAudioUrl.isEmpty ? null : rawAudioUrl,
      effectUsed:
          (rawEffectUsed.isEmpty || rawEffectUsed == 'Ninguno')
              ? null
              : rawEffectUsed,
      effectVideoUrl: rawEffectUrl.isEmpty ? null : rawEffectUrl,
      caption: (data['caption'] ?? '').toString(),
      hashtags: List<String>.from(data['hashtags'] ?? const <String>[]),
      likes: (rawLikes is num)
          ? rawLikes.toInt()
          : int.tryParse(rawLikes.toString()) ?? 0,
      comments: (rawComments is num)
          ? rawComments.toInt()
          : int.tryParse(rawComments.toString()) ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? const <String>[]),
    );
  }

  VideoPost copyWith({
    String? id,
    AppUser? author,
    String? videoUrl,
    String? imageUrl,
    String? audioName,
    String? audioUrl,
    String? effectUsed,
    String? effectVideoUrl,
    String? caption,
    List<String>? hashtags,
    int? likes,
    int? comments,
    List<String>? likedBy,
  }) {
    return VideoPost(
      id: id ?? this.id,
      author: author ?? this.author,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      audioName: audioName ?? this.audioName,
      audioUrl: audioUrl ?? this.audioUrl,
      effectUsed: effectUsed ?? this.effectUsed,
      effectVideoUrl: effectVideoUrl ?? this.effectVideoUrl,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}