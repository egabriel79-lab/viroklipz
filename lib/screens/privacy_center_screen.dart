import 'package:flutter/material.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  String _lang = 'ES';

  Widget _buildFooterGroup(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
          ),
        ],
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
        title: const Text(
          'Centro de privacidad',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFE91E63), Color(0xFF673AB7)],
              ),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _lang = _lang == 'ES' ? 'EN' : 'ES';
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _lang,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            SizedBox(
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=900&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Viroklipz protege tu privacidad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            // Bloque de texto en negro puro
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: const Text(
                'En Viroklipz, tu privacidad es una prioridad absoluta. Trabajamos cada día para proteger tu información personal, ofrecerte controles transparentes y garantizar una experiencia segura en toda nuestra comunidad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            // Imagen central (dos personas usando laptops)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=900&auto=format&fit=crop',
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Sección Qué hacemos
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                children: [
                  const Text(
                    'Qué hacemos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Diseñamos herramientas avanzadas de seguridad y privacidad integradas en tu cuenta para que decidas quién ve tu contenido, cómo se gestionan tus permisos y qué datos compartes dentro de Viroklipz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Sección Política de privacidad multilingüe (fondo claro)
            Container(
              color: const Color(0xFFF4F4F5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'La Política de privacidad está disponible en diferentes idiomas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Más información ↗',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Footer Menu + Copyright
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
              child: Column(
                children: [
                  _buildFooterGroup('Compañía', [
                    'Acerca de Viroklipz',
                    'Sala de prensa',
                    'Empleos',
                    'Contacto',
                  ]),
                  _buildFooterGroup('Programas', [
                    'Viroklipz for Good',
                    'Viroklipz Plus',
                    'Creadores',
                    'Publicidad',
                  ]),
                  _buildFooterGroup('Recursos', [
                    'Centro de ayuda',
                    'Centro de seguridad',
                    'Normas de la comunidad',
                    'Transparencia',
                  ]),
                  _buildFooterGroup('Avisos legales', [
                    'Términos del servicio',
                    'Política de privacidad',
                    'Política de cookies',
                    'Propiedad intelectual',
                  ]),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 Viroklipz',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}