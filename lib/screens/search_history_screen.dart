import 'package:flutter/material.dart';

class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'date': 'Ayer',
        'items': [
          {'query': 'mi próximo auto', 'time': '10:31 p. m.'},
          {'query': 'transiciones rápidas video vertical', 'time': '7:14 p. m.'},
        ],
      },
      {
        'date': '12 de noviembre',
        'items': [
          {'query': 'beats lo-fi sin copyright', 'time': '4:05 p. m.'},
          {'query': 'mejores cámaras 4k para vlogs', 'time': '11:20 a. m.'},
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
          'Historial de búsqueda',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Seleccionar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
                        leading: const Icon(Icons.search, color: Colors.grey),
                        title: Text(
                          item['query']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          item['time']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
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