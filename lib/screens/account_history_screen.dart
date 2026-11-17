import 'package:flutter/material.dart';

class AccountHistoryScreen extends StatelessWidget {
  const AccountHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'date': 'Hoy',
        'events': [
          {
            'device': 'iPhone 15 Pro',
            'location': 'Madrid, España',
            'time': '10:15 a. m.',
          },
        ],
      },
      {
        'date': '12 de noviembre',
        'events': [
          {
            'device': 'Samsung Galaxy S24',
            'location': 'Barcelona, España',
            'time': '8:47 p. m.',
          },
        ],
      },
      {
        'date': '5 de noviembre',
        'events': [
          {
            'device': 'Navegador Web (macOS)',
            'location': 'Madrid, España',
            'time': '6:12 p. m.',
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
          'Historial de la cuenta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Se mostrará el historial de la cuenta correspondiente al último año. Revisa tus inicios de sesión recientes.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sections.map((section) {
            final events = section['events'] as List<Map<String, String>>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 8),
                  child: Text(
                    section['date'] as String,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...events.map((event) => Card(
                      color: const Color(0xFF1C1C1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.login_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Inicio de sesión',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Iniciaste sesión en tu cuenta desde un ${event['device']} ubicado en ${event['location']}.',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    event['time']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}