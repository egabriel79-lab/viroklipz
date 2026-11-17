import 'package:flutter/material.dart';

class DownloadsSettingsScreen extends StatefulWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  State<DownloadsSettingsScreen> createState() =>
      _DownloadsSettingsScreenState();
}

class _DownloadsSettingsScreenState extends State<DownloadsSettingsScreen> {
  bool _downloadsEnabled = true;

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
          'Descargas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _downloadsEnabled,
              activeTrackColor: const Color(0xFFFF5722),
              title: const Text(
                'Descargas de videos',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Permite que otras personas descarguen tus videos y los compartan en otras plataformas. Si desactivas esta opción, nadie podrá descargar tus publicaciones futuras.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _downloadsEnabled = val),
            ),
          ),
        ],
      ),
    );
  }
}