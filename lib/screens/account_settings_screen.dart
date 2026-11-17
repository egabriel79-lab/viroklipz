import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  void _showOptionFeedback(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cuenta: $title'),
        backgroundColor: const Color(0xFF27272A),
        duration: const Duration(seconds: 1),
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cuenta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
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
                _buildAccountItem(
                  context,
                  title: 'Información de la cuenta',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Contraseña',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Verificación',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Pasar a Cuenta de empresa verificada',
                  subtitle:
                      'Estás usando una cuenta personal actualmente. Cambia a una cuenta de empresa para acceder a más herramientas.',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Legado de la cuenta',
                  subtitle:
                      'Planifica con antelación qué ocurrirá con tu cuenta si algo llega a suceder.',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Descargar tus datos',
                  subtitle: 'Obtén una copia de tus datos de Viroklipz.',
                ),
                _buildDivider(),
                _buildAccountItem(
                  context,
                  title: 'Desactivar o eliminar la cuenta',
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
    );
  }

  Widget _buildAccountItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () => _showOptionFeedback(context, title),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.redAccent : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }
}