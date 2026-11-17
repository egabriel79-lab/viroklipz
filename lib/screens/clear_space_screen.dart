import 'package:flutter/material.dart';

class ClearSpaceScreen extends StatefulWidget {
  const ClearSpaceScreen({super.key});

  @override
  State<ClearSpaceScreen> createState() => _ClearSpaceScreenState();
}

class _ClearSpaceScreenState extends State<ClearSpaceScreen> {
  bool _cacheCleared = false;

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
          'Liberar espacio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Datos de Viroklipz',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _cacheCleared ? '0.0 MB' : 'Calculando...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _cacheCleared ? 0.08 : 0.62,
              minHeight: 10,
              backgroundColor: const Color(0xFF27272A),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Caché:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _cacheCleared
                            ? 'La memoria caché temporal se ha limpiado correctamente.'
                            : 'Borrar la memoria caché para liberar espacio. Esto no afectará a tu experiencia en Viroklipz.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cacheCleared
                        ? Colors.grey[800]
                        : const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _cacheCleared
                      ? null
                      : () {
                          setState(() => _cacheCleared = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Memoria caché liberada'),
                            ),
                          );
                        },
                  child: Text(_cacheCleared ? 'Listo' : 'Borrar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'La memoria caché incluye archivos temporales descargados mientras navegas para acelerar la carga de videos e imágenes. Al borrarla no se eliminarán tus borradores, publicaciones ni cuenta.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}