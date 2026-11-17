import 'package:flutter/material.dart';

class DataSaverScreen extends StatefulWidget {
  const DataSaverScreen({super.key});

  @override
  State<DataSaverScreen> createState() => _DataSaverScreenState();
}

class _DataSaverScreenState extends State<DataSaverScreen> {
  bool _dataSaverEnabled = false;

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
          'Ahorro de datos',
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
              value: _dataSaverEnabled,
              activeTrackColor: const Color(0xFFE91E63),
              title: const Text(
                'Ahorro de datos',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Reduce el consumo de datos móviles cuando no estés conectado a una red Wi-Fi. Es posible que los videos tarden un poco más en cargarse o se muestren en menor resolución.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _dataSaverEnabled = val),
            ),
          ),
        ],
      ),
    );
  }
}