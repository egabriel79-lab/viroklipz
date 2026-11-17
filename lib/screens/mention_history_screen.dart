import 'package:flutter/material.dart';

class MentionHistoryScreen extends StatelessWidget {
  const MentionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'date': 'Ayer',
        'items': [
          {
            'name': 'Mateo Cine',
            'avatar':
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
            'time': '9:18 p. m.',
            'thumb':
                'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=200&auto=format&fit=crop',
          },
          {
            'name': 'Valeria Beats',
            'avatar':
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop',
            'time': '3:42 p. m.',
            'thumb':
                'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=200&auto=format&fit=crop',
          },
        ],
      },
      {
        'date': '10 de noviembre',
        'items': [
          {
            'name': 'Sofía Fit',
            'avatar':
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop',
            'time': '12:05 p. m.',
            'thumb':
                'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=200&auto=format&fit=crop',
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
        centerTitle: true,
        title: const Text(
          'Historial de menciones',
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
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item['avatar']!),
                        ),
                        title: Text(
                          '${item['name']} te mencionó en una foto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          item['time']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['thumb']!,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                          ),
                        ),
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