class VideoModel {
  final String id;
  final String userId;
  final String username;
  final String videoUrl;
  final String description;
  final String audioName;
  final int likesCount;

  const VideoModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.videoUrl,
    required this.description,
    required this.audioName,
    required this.likesCount,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      username: (map['username'] ?? 'usuario').toString(),
      videoUrl: (map['video_url'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      audioName: (map['audio_name'] ?? 'Sonido original').toString(),
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'username': username,
      'video_url': videoUrl,
      'description': description,
      'audio_name': audioName,
      'likes_count': likesCount,
    };
  }
}