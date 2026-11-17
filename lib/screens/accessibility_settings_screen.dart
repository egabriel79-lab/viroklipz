import 'package:flutter/material.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  bool _highContrast = false;
  bool _skipPhotosensitive = false;
  bool _subtitles = false;
  bool _reducedMotion = true;
  bool _fasterScroll = true;
  bool _animatedThumbnails = false;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
          'Accesibilidad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Aspecto'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Tamaño de texto',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _highContrast,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Aumenta el contraste de color',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _highContrast = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Contenido'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _skipPhotosensitive,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Omitir publicaciones no aptas para fotosensibles',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) =>
                      setState(() => _skipPhotosensitive = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _subtitles,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Subtítulos',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _subtitles = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Movimiento'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _reducedMotion,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Reduced motion',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _reducedMotion = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _fasterScroll,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Mayor velocidad de desplazamiento',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _fasterScroll = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _animatedThumbnails,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Miniaturas animadas',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) =>
                      setState(() => _animatedThumbnails = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}