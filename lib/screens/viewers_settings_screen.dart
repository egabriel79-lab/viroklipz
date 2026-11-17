import 'package:flutter/material.dart';

class ViewersSettingsScreen extends StatefulWidget {
  const ViewersSettingsScreen({super.key});

  @override
  State<ViewersSettingsScreen> createState() => _ViewersSettingsScreenState();
}

class _ViewersSettingsScreenState extends State<ViewersSettingsScreen> {
  bool _showBanner = true;
  bool _viewerHistory = true;

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
          'Espectadores',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_showBanner)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Ahora los historiales de visitas al perfil y visualizaciones de publicaciones se fusionan en un único panel de espectadores.',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => setState(() => _showBanner = false),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _viewerHistory,
              activeTrackColor: const Color(0xFFFF5722),
              title: const Text(
                'Historial de espectadores',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Mira quién vio tus publicaciones durante los últimos 7 días y permite que tus seguidores vean cuando tú visualizas sus clips.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _viewerHistory = val),
            ),
          ),
        ],
      ),
    );
  }
}