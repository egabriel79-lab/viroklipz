import 'package:flutter/material.dart';

class MusicSettingsScreen extends StatefulWidget {
  const MusicSettingsScreen({super.key});

  @override
  State<MusicSettingsScreen> createState() => _MusicSettingsScreenState();
}

class _MusicSettingsScreenState extends State<MusicSettingsScreen> {
  bool _linked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Música',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Aplicación de música',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text(
                'Agregar a la aplicación de música',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _linked ? 'Vinculada' : 'Vincular',
                    style: TextStyle(
                      color: _linked ? const Color(0xFFE91E63) : Colors.grey[300],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ],
              ),
              onTap: () => setState(() => _linked = !_linked),
            ),
          ),
        ],
      ),
    );
  }
}