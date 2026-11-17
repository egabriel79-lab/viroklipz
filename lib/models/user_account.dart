class UserAccount {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final int unreadCount;

  const UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.unreadCount = 0,
  });

  UserAccount copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? unreadCount,
  }) {
    return UserAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}