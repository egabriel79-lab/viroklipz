import 'package:flutter/material.dart';

class LiteModeScreen extends StatefulWidget {
  const LiteModeScreen({super.key});

  @override
  State<LiteModeScreen> createState() => _LiteModeScreenState();
}

class _LiteModeScreenState extends State<LiteModeScreen> {
  bool _liteModeEnabled = true;

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
          'Modo lite',
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
              value: _liteModeEnabled,
              activeTrackColor: const Color(0xFFE91E63),
              title: const Text(
                'Modo lite',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Optimiza el rendimiento de Viroklipz, reduce el uso de batería y disminuye el consumo de datos al reproducir videos en redes lentas.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _liteModeEnabled = val),
            ),
          ),
        ],
      ),
    );
  }
}