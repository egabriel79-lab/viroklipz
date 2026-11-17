import 'package:flutter/material.dart';

class AdActivityHistoryScreen extends StatelessWidget {
  const AdActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Historial de actividad de anuncios',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Historial de anuncios'),
              Tab(text: 'Historial de enlaces'),
              Tab(text: 'Reseñas de anuncios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No hay historial de anuncios',
              description:
                  'Aquí aparecerán los anuncios que hayas visto o con los que hayas interactuado recientemente en Viroklipz.',
            ),
            _buildEmptyState(
              icon: Icons.link_outlined,
              title: 'No hay historial de enlaces',
              description:
                  'Cuando abras enlaces externos desde promociones patrocinadas, se guardarán aquí.',
            ),
            _buildEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No hay reseñas de anuncios',
              description:
                  'Tus valoraciones y comentarios sobre anuncios relevantes aparecerán en esta pestaña.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}