import 'package:flutter/material.dart';

class AudienceControlScreen extends StatefulWidget {
  const AudienceControlScreen({super.key});

  @override
  State<AudienceControlScreen> createState() => _AudienceControlScreenState();
}

class _AudienceControlScreenState extends State<AudienceControlScreen> {
  bool _adultsOnly = false;

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
          'Control del público',
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
              value: _adultsOnly,
              activeTrackColor: const Color(0xFFE91E63),
              title: const Text(
                'Mayores de 18 años',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Activa este ajuste si tu contenido está pensado únicamente para público adulto. Las publicaciones restringidas solo serán visibles para usuarios mayores de 18 años.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _adultsOnly = val),
            ),
          ),
        ],
      ),
    );
  }
}