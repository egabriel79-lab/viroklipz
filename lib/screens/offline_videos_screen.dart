import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/video_post.dart';

class OfflineVideosScreen extends StatefulWidget {
  const OfflineVideosScreen({super.key});

  @override
  State<OfflineVideosScreen> createState() => _OfflineVideosScreenState();
}

class _OfflineVideosScreenState extends State<OfflineVideosScreen> {
  final PageController _pageController = PageController();
  late final List<VideoPost> _offlineVideos;
  final Set<int> _likedIndices = {};
  final Set<int> _savedIndices = {};

  static const List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=800&auto=format&fit=crop',
  ];

  static const List<String> _sampleUsernames = [
    'fugr356',
    'mateo.cine',
    'valeria.flow',
    'lucas.ruta',
    'sofia.beats',
    'diego.35mm',
    'tallermadera',
  ];

  @override
  void initState() {
    super.initState();
    _offlineVideos = _generate300OfflineVideos();
  }

  List<VideoPost> _generate300OfflineVideos() {
    final List<VideoPost> list = [];
    for (int i = 0; i < 300; i++) {
      final String username =
          i == 0 ? 'fugr356' : _sampleUsernames[i % _sampleUsernames.length];
      final String mediaUrl = _sampleImages[i % _sampleImages.length];

      list.add(
        VideoPost(
          id: 'offline_${i + 1}',
          author: AppUser(
            id: 'offline_author_$i',
            username: username,
            avatarUrl: mediaUrl,
          ),
          videoUrl: mediaUrl,
          caption:
              '#StressRelief#PopularScience#Tips Construyendo clips sin conexión (#${i + 1})',
          likes: i == 0 ? 3667 : 540 + ((i * 137) % 9200),
        ),
      );
    }
    return list;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Feed vertical de 300 videos
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _offlineVideos.length,
                  itemBuilder: (context, index) {
                    final VideoPost post = _offlineVideos[index];
                    final bool isLiked = _likedIndices.contains(index);
                    final bool isSaved = _savedIndices.contains(index);
                    final int displayLikes = post.likes + (isLiked ? 1 : 0);
                    final int displayComments = index == 0 ? 22 : 12 + (index % 90);
                    final int displayBookmarks =
                        (index == 0 ? 487 : 40 + (index % 320)) + (isSaved ? 1 : 0);
                    final int displayShares = index == 0 ? 243 : 18 + (index % 180);

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          post.videoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF161618),
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        ),

                        // Scrim para legibilidad
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                                Colors.black.withOpacity(0.82),
                              ],
                              stops: const [0.0, 0.35, 1.0],
                            ),
                          ),
                        ),

                        // Barra lateral derecha superpuesta
                        Positioned(
                          right: 12,
                          bottom: 18,
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage:
                                        NetworkImage(post.author.avatarUrl),
                                  ),
                                  Positioned(
                                    bottom: -8,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF2D55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              _buildSideAction(
                                icon: isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? const Color(0xFFFF2D55)
                                    : Colors.white,
                                count: '$displayLikes',
                                onTap: () {
                                  setState(() {
                                    if (isLiked) {
                                      _likedIndices.remove(index);
                                    } else {
                                      _likedIndices.add(index);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildSideAction(
                                icon: Icons.chat_bubble_rounded,
                                color: Colors.white,
                                count: '$displayComments',
                                onTap: () {},
                              ),
                              const SizedBox(height: 16),
                              _buildSideAction(
                                icon: isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isSaved ? Colors.amber : Colors.white,
                                count: '$displayBookmarks',
                                onTap: () {
                                  setState(() {
                                    if (isSaved) {
                                      _savedIndices.remove(index);
                                    } else {
                                      _savedIndices.add(index);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildSideAction(
                                icon: Icons.reply,
                                color: Colors.white,
                                count: '$displayShares',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        // Información inferior izquierda + barra de búsqueda
                        Positioned(
                          left: 14,
                          right: 76,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    post.author.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    index == 0 ? '· 11-05' : '· 11-${((index + 4) % 28 + 1).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Barra de búsqueda inferior semi-transparente
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Búsqueda · barcos pequeños de madera >',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Barra superior superpuesta (Atrás y Ajustes)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Banner fijo de modo offline (negro puro)
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Text(
                'Estás mirando vídeos sin conexión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideAction({
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 3),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}