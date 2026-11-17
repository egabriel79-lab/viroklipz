import 'package:flutter/material.dart';

class PlaybackSettingsScreen extends StatefulWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  State<PlaybackSettingsScreen> createState() => _PlaybackSettingsScreenState();
}

class _PlaybackSettingsScreenState extends State<PlaybackSettingsScreen> {
  bool _openMuted = false;
  bool _autoVolume = true;
  bool _autoRotate = false;
  bool _showObjectTags = true;

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
          'Reproducción',
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
            child: Column(
              children: [
                SwitchListTile(
                  value: _openMuted,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Abrir Viroklipz en silencio',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Los videos permanecerán silenciados hasta que presiones el control de volumen.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _openMuted = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _autoVolume,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Ajuste automático del volumen',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Equilibra automáticamente el nivel de audio entre distintos clips.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _autoVolume = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _autoRotate,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Rotación automática',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Adapta la orientación de pantalla al girar el dispositivo.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _autoRotate = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _showObjectTags,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Mostrar etiquetas de objetos',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Muestra información contextual sobre productos y elementos en pantalla.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _showObjectTags = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}