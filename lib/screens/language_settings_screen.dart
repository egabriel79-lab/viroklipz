import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  bool _alwaysTranslate = false;

  Widget _buildTrailingValue(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, color: Colors.grey[500]),
      ],
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
          'Idiomas',
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
            child: ListTile(
              title: const Text(
                'Idioma de la aplicación',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              trailing: _buildTrailingValue('Español'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Traducción',
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
            child: Column(
              children: [
                SwitchListTile(
                  value: _alwaysTranslate,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Traducir siempre las publicaciones',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Traduce automáticamente descripciones y comentarios a tu idioma preferido.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _alwaysTranslate = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Traducir a',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: _buildTrailingValue('Español'),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'No traducir',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: _buildTrailingValue('Español'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}