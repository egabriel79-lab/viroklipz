import 'package:flutter/material.dart';

class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _publications = const [
    {
      'url':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400&auto=format&fit=crop',
      'views': '157',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=400&auto=format&fit=crop',
      'views': '412',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&auto=format&fit=crop',
      'views': '1.2K',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&auto=format&fit=crop',
      'views': '893',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&auto=format&fit=crop',
      'views': '2.4K',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=400&auto=format&fit=crop',
      'views': '645',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Recientes',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 92),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 9 / 16,
            ),
            itemCount: _publications.length,
            itemBuilder: (context, index) {
              final item = _publications[index];
              final bool isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: const Color(0xFFFF2D55), width: 2.5)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(item['url']!, fit: BoxFit.cover),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item['views']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Botón flotante tipo píldora "Siguiente"
          Positioned(
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF2D55), Color(0xFFFF6B35)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D55).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    Navigator.pop(
                      context,
                      _publications[_selectedIndex]['url'],
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Siguiente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}