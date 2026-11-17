import 'package:flutter/material.dart';
import 'help_category_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _openMore(BuildContext context, int initialTabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HelpCategoryScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  Widget _buildFaqTab({
    required BuildContext context,
    required List<String> items,
    required int categoryTabIndex,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      items[index],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: Colors.grey[500]),
                    onTap: () => _openMore(context, categoryTabIndex),
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, color: Colors.white10),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _openMore(context, categoryTabIndex),
          child: const Text('Ver más'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<String> guideFaqs = [
      'Cómo crear y publicar videos en Viroklipz',
      'Edición, filtros, música y efectos',
      'Configurar tu perfil y privacidad',
      'Administrar notificaciones y feed Radar',
      'Seguridad y verificación de la cuenta',
    ];

    const List<String> monetizationFaqs = [
      'Viroklipz Plus',
      'Artículos no recibidos',
      'Commercial Content Library',
      'About AI-generated content',
      'Propiedad intelectual',
    ];

    const List<String> otherFaqs = [
      '¿Qué tipos de suscripciones existen?',
      '¿Por qué no puedo renovar mi suscripción?',
      '¿Cómo me suscribo a la comunidad de un creador...?',
      '¿Dónde puedo ver mis suscripciones?',
      '¿Cómo puedo cancelar una suscripción...?',
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            'Centro de ayuda',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE91E63),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Guía de uso'),
              Tab(text: 'Monetización'),
              Tab(text: 'Otros'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildFaqTab(
                    context: context,
                    items: guideFaqs,
                    categoryTabIndex: 2,
                  ),
                  _buildFaqTab(
                    context: context,
                    items: monetizationFaqs,
                    categoryTabIndex: 0,
                  ),
                  _buildFaqTab(
                    context: context,
                    items: otherFaqs,
                    categoryTabIndex: 1,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Chatea con nosotros',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Iniciando chat de soporte...'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}