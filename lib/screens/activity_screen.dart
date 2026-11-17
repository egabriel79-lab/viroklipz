import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F0F),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Actividad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF2D55),
            indicatorWeight: 2.5,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF71717A),
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Actividad'),
              Tab(text: 'Nuevos seguidores'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ActivityTabContent(),
            NewFollowersTabContent(),
          ],
        ),
      ),
    );
  }
}

class _RecommendedUser {
  final String id;
  final String name;
  final String subtitle;
  final String avatarUrl;
  final String initials;
  final List<String> videoThumbnails;

  const _RecommendedUser({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.initials,
    required this.videoThumbnails,
  });
}

const List<_RecommendedUser> _mockRecommendedUsers = [
  _RecommendedUser(
    id: 'rec_1',
    name: 'mateo.cine',
    subtitle: 'Compartió videos contigo',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
    initials: 'MC',
    videoThumbnails: [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1536240478700-b869070f9279?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300&auto=format&fit=crop',
    ],
  ),
  _RecommendedUser(
    id: 'rec_2',
    name: 'sofia.beats',
    subtitle: 'Compartió videos contigo',
    avatarUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop',
    initials: 'SB',
    videoThumbnails: [
      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&auto=format&fit=crop',
    ],
  ),
  _RecommendedUser(
    id: 'rec_3',
    name: 'diego.skate',
    subtitle: 'Compartió videos contigo',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop',
    initials: 'DS',
    videoThumbnails: [
      'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1520045892732-304bc3ac5d8e?w=300&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=300&auto=format&fit=crop',
    ],
  ),
];

class ActivityTabContent extends StatefulWidget {
  const ActivityTabContent({super.key});

  @override
  State<ActivityTabContent> createState() => _ActivityTabContentState();
}

class _ActivityTabContentState extends State<ActivityTabContent> {
  final Set<String> _followedIds = {};
  final Set<String> _dismissedIds = {};
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visibleRecommended = _mockRecommendedUsers
        .where((u) => !_dismissedIds.contains(u.id))
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Notificación 1
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const _RoundAvatar(
            url:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
            initials: 'NA',
          ),
          title: RichText(
            text: const TextSpan(
              style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13.5),
              children: [
                TextSpan(
                  text: 'NANCY🦋 ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: 'le dio me gusta a tu comentario'),
              ],
            ),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              '2 d',
              style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
            ),
          ),
        ),

        // Notificación 2 (Avatares superpuestos)
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: SizedBox(
            width: 48,
            height: 44,
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  top: 0,
                  child: _RoundAvatar(
                    url:
                        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop',
                    initials: 'VL',
                    size: 32,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0F0F0F),
                        width: 2,
                      ),
                    ),
                    child: const _RoundAvatar(
                      url:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
                      initials: 'RA',
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: RichText(
            text: const TextSpan(
              style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13.5),
              children: [
                TextSpan(
                  text: 'Valery🦋, Richard.A y Alix ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: 'han visto tu perfil'),
              ],
            ),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              '2 d',
              style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
            ),
          ),
        ),

        if (_showAll)
          const ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _RoundAvatar(
              url:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop',
              initials: 'LR',
            ),
            title: Text(
              'lucas.ruta comentó tu video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '4 d',
              style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
            ),
          ),

        // Ver todo centrado
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showAll = !_showAll),
            icon: Icon(
              _showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFA1A1AA),
              size: 18,
            ),
            label: Text(
              _showAll ? 'Ver menos' : 'Ver todo',
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (visibleRecommended.isNotEmpty) ...[
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Cuentas recomendadas',
              style: TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...visibleRecommended.map((user) {
            final bool isFollowing = _followedIds.contains(user.id);
            return _RecommendedAccountRow(
              user: user,
              isFollowing: isFollowing,
              onFollowTap: () {
                setState(() {
                  if (isFollowing) {
                    _followedIds.remove(user.id);
                  } else {
                    _followedIds.add(user.id);
                  }
                });
              },
              onDismissTap: () => setState(() => _dismissedIds.add(user.id)),
            );
          }),
        ],
      ],
    );
  }
}

class NewFollowersTabContent extends StatefulWidget {
  const NewFollowersTabContent({super.key});

  @override
  State<NewFollowersTabContent> createState() => _NewFollowersTabContentState();
}

class _NewFollowersTabContentState extends State<NewFollowersTabContent> {
  final Set<String> _followedIds = {};
  final Set<String> _dismissedIds = {};
  bool _showAll = false;

  static const List<Map<String, String>> _followers = [
    {
      'id': 'f1',
      'name': 'Proyectos Yomi c.a',
      'time': '2 d',
      'initials': 'PY',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop',
    },
    {
      'id': 'f2',
      'name': 'Valery🦋',
      'time': '3 d',
      'initials': 'VL',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
    },
    {
      'id': 'f3',
      'name': 'Panelscleandr',
      'time': '4 d',
      'initials': 'PC',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final visibleRecommended = _mockRecommendedUsers
        .where((u) => !_dismissedIds.contains(u.id))
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ..._followers.map((follower) {
          final id = follower['id']!;
          final bool isFollowing = _followedIds.contains(id);

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _RoundAvatar(
              url: follower['avatar']!,
              initials: follower['initials']!,
            ),
            title: Text(
              follower['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'empezó a seguirte. ${follower['time']}',
              style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12.5),
            ),
            trailing: _FollowButton(
              isFollowing: isFollowing,
              onTap: () {
                setState(() {
                  if (isFollowing) {
                    _followedIds.remove(id);
                  } else {
                    _followedIds.add(id);
                  }
                });
              },
            ),
          );
        }),

        if (_showAll)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const _RoundAvatar(
              url:
                  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop',
              initials: '13',
            ),
            title: const Text(
              '1382jovana🇻🇪',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'empezó a seguirte. 6 d',
              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12.5),
            ),
            trailing: _FollowButton(
              isFollowing: _followedIds.contains('f4'),
              onTap: () {
                setState(() {
                  if (_followedIds.contains('f4')) {
                    _followedIds.remove('f4');
                  } else {
                    _followedIds.add('f4');
                  }
                });
              },
            ),
          ),

        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _showAll = !_showAll),
            icon: Icon(
              _showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFA1A1AA),
              size: 18,
            ),
            label: Text(
              _showAll ? 'Ver menos' : 'Ver todo',
              style: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (visibleRecommended.isNotEmpty) ...[
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Cuentas recomendadas',
              style: TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...visibleRecommended.map((user) {
            final bool isFollowing = _followedIds.contains(user.id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RecommendedAccountRow(
                  user: user,
                  isFollowing: isFollowing,
                  onFollowTap: () {
                    setState(() {
                      if (isFollowing) {
                        _followedIds.remove(user.id);
                      } else {
                        _followedIds.add(user.id);
                      }
                    });
                  },
                  onDismissTap: () =>
                      setState(() => _dismissedIds.add(user.id)),
                ),
                // Fila de 3-4 miniaturas de video rectangulares
                Padding(
                  padding: const EdgeInsets.fromLTRB(74, 2, 16, 14),
                  child: Row(
                    children: user.videoThumbnails.take(4).map((thumbUrl) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    thumbUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFF1F1F23),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    left: 4,
                                    bottom: 4,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
        ],
      ],
    );
  }
}

class _RecommendedAccountRow extends StatelessWidget {
  final _RecommendedUser user;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onDismissTap;

  const _RecommendedAccountRow({
    required this.user,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _RoundAvatar(url: user.avatarUrl, initials: user.initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FollowButton(isFollowing: isFollowing, onTap: onFollowTap),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDismissTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF71717A),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFollowing ? const Color(0xFF27272A) : const Color(0xFFFF2D55),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: isFollowing
                ? BorderSide(color: Colors.white.withValues(alpha: 0.15))
                : BorderSide.none,
          ),
        ),
        child: Text(
          isFollowing ? 'Siguiendo' : 'Seguir también',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _RoundAvatar extends StatelessWidget {
  final String url;
  final String initials;
  final double size;

  const _RoundAvatar({
    required this.url,
    required this.initials,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF27272A),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}