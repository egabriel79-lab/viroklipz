import 'package:flutter/material.dart';

class ContentReuseHistoryScreen extends StatelessWidget {
  const ContentReuseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'date': 'Esta semana',
        'items': [
          {
            'thumb':
                'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=200&auto=format&fit=crop',
            'hashtags': '#desarrollopersonal #gabriel #mentalidad',
            'count': '1 publicación',
          },
          {
            'thumb':
                'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=200&auto=format&fit=crop',
            'hashtags': '#beats #musicaproduccion #studio',
            'count': '3 publicaciones',
          },
        ],
      },
      {
        'date': 'Noviembre',
        'items': [
          {
            'thumb':
                'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=200&auto=format&fit=crop',
            'hashtags': '#fotografia #35mm #viajes',
            'count': '1 publicación',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historial de reutilización de...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          final items = section['items'] as List<Map<String, String>>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Text(
                  section['date'] as String,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...items.map((item) => Column(
                    children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['thumb']!,
                            width: 44,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item['hashtags']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.repeat_rounded,
                                color: Colors.grey,
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['count']!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white38,
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Colors.white10),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }
}