import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Política de privacidad',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegalHeaderCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidad de Viroklipz',
              subtitle: 'Última actualización: Noviembre 2026',
            ),
            const SizedBox(height: 16),
            _LegalSectionCard(
              title: '1. Recopilación de datos en Viroklipz',
              body:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viroklipz recopila únicamente la información necesaria para operar tu perfil de creador, como tu correo electrónico, nombre de usuario, avatar, videos subidos y token FCM para notificaciones push. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
            const SizedBox(height: 12),
            _LegalSectionCard(
              title: '2. Cámara, micrófono, galería y código QR',
              body:
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Viroklipz solicita acceso a cámara, micrófono y galería exclusivamente para grabar videos, escanear perfiles QR y guardar contenido cuando tú lo autorizas. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.',
            ),
            const SizedBox(height: 12),
            _LegalSectionCard(
              title: '3. Seguridad, menores de edad y eliminación de cuenta',
              body:
                  'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Puedes solicitar la eliminación permanente de tu cuenta y datos personales en cualquier momento desde Ajustes o el menú de Perfil en Viroklipz.',
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                '© 2026 Viroklipz · Todos los derechos reservados',
                style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LegalHeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LegalHeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  final String title;
  final String body;

  const _LegalSectionCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFD4D4D8),
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}