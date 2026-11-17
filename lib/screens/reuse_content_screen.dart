import 'package:flutter/material.dart';

class ReuseContentScreen extends StatelessWidget {
  const ReuseContentScreen({super.key});

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
          'Reutilizar contenido',
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
                ListTile(
                  title: const Text(
                    'Permite reutilizar contenido desde',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Elige quién puede reutilizar tus videos y fotos en nuevas creaciones.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Todo el m...',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Colors.grey[500]),
                    ],
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Historial de reutilización de contenido',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Consulta qué creadores han utilizado tus clips o sonidos.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
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