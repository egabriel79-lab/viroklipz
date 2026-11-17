import 'package:flutter/material.dart';

class DirectMessagesSettingsScreen extends StatefulWidget {
  const DirectMessagesSettingsScreen({super.key});

  @override
  State<DirectMessagesSettingsScreen> createState() =>
      _DirectMessagesSettingsScreenState();
}

class _DirectMessagesSettingsScreenState
    extends State<DirectMessagesSettingsScreen> {
  bool _readStatus = true;
  bool _safeMode = true;
  String _activityStatus = 'Público';

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
          'Mensajes directos',
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
                'Ajustes de permisos',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Preferencias de mensajes',
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
                  value: _readStatus,
                  activeTrackColor: const Color(0xFFFF5722),
                  title: const Text(
                    'Estado de lectura',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Las personas pueden ver cuándo leíste sus mensajes si ambos tienen esta función activada.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _readStatus = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Estado de actividad',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _activityStatus,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Colors.grey[500]),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _activityStatus = _activityStatus == 'Público'
                          ? 'Solo amigos'
                          : 'Público';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Herramientas de seguridad',
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
                  value: _safeMode,
                  activeTrackColor: const Color(0xFFFF5722),
                  title: const Text(
                    'Modo seguro',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Filtra automáticamente mensajes que podrían contener contenido ofensivo.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _safeMode = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Palabras clave filtradas',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
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