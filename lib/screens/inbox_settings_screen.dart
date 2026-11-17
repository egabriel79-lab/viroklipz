import 'package:flutter/material.dart';

class InboxSettingsScreen extends StatefulWidget {
  const InboxSettingsScreen({super.key});

  @override
  State<InboxSettingsScreen> createState() => _InboxSettingsScreenState();
}

class _InboxSettingsScreenState extends State<InboxSettingsScreen> {
  String _selectedMode = 'personal';

  Widget _buildExperienceCard({
    required String id,
    required String title,
    required List<String> bullets,
  }) {
    final bool isSelected = _selectedMode == id;
    const Color pinkAccent = Color(0xFFE91E63);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? pinkAccent : Colors.white10,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedMode = id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Radio<String>(
                    value: id,
                    groupValue: _selectedMode,
                    activeColor: pinkAccent,
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => isSelected ? pinkAccent : Colors.grey,
                    ),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMode = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyle(color: Colors.grey[300], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selecciona una experiencia de mensajería',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildExperienceCard(
            id: 'personal',
            title: 'Personal: chatea con amigos',
            bullets: [
              'Herramientas de mensajería básicas',
              'Recibir todas las notificaciones',
            ],
          ),
          _buildExperienceCard(
            id: 'profesional',
            title: 'Profesional: interactúa con tus seguidores',
            bullets: [
              'Herramientas avanzadas de mensajería y respuestas rápidas',
              'Carpetas separadas para mensajes principales y solicitudes',
              'Control de notificaciones para creadores',
            ],
          ),
        ],
      ),
    );
  }
}