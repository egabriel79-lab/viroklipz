import 'package:flutter/material.dart';

class SearchWallpaperScreen extends StatefulWidget {
  const SearchWallpaperScreen({super.key});

  @override
  State<SearchWallpaperScreen> createState() => _SearchWallpaperScreenState();
}

class _SearchWallpaperScreenState extends State<SearchWallpaperScreen> {
  final TextEditingController _searchController =
      TextEditingController(text: 'Live Wallpaper');

  final List<Map<String, dynamic>> _items = const [
    {
      'title': 'Cyber Astronaut',
      'author': '@neon_pulse',
      'likes': '18.4K',
      'isVideo': true,
      'image':
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&auto=format&fit=crop',
    },
    {
      'title': 'Templo Dorado',
      'author': '@zen_visuals',
      'likes': '9.2K',
      'isVideo': true,
      'image':
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
    },
    {
      'title': 'Ciudad Nocturna 4K',
      'author': '@mateo_fx',
      'likes': '24.1K',
      'isVideo': true,
      'image':
          'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=600&auto=format&fit=crop',
    },
    {
      'title': 'Aesthetic Sunset',
      'author': '@valeria_art',
      'likes': '12.7K',
      'isVideo': false,
      'image':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&auto=format&fit=crop',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildWallpaperGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(item['image'] as String, fit: BoxFit.cover),
                    if (item['isVideo'] == true)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['author'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Color(0xFFE91E63),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['likes'] as String,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE91E63),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Tendencias'),
              Tab(text: 'Videos'),
              Tab(text: 'Fotos'),
              Tab(text: 'Usuarios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWallpaperGrid(),
            _buildWallpaperGrid(),
            _buildWallpaperGrid(),
            _buildWallpaperGrid(),
          ],
        ),
      ),
    );
  }
}