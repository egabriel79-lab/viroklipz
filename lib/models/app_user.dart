class AppUser {
  final String id;
  final String username;
  final String avatarUrl;

  AppUser({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: (map['id'] ?? '').toString(),
      username: (map['username'] ?? 'usuario').toString(),
      avatarUrl: (map['avatar_url'] ?? '').toString(),
    );
  }
}