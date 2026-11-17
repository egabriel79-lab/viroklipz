import 'package:flutter/material.dart';

class SecurityPermissionsScreen extends StatefulWidget {
  const SecurityPermissionsScreen({super.key});

  @override
  State<SecurityPermissionsScreen> createState() =>
      _SecurityPermissionsScreenState();
}

class _SecurityPermissionsScreenState extends State<SecurityPermissionsScreen> {
  bool _saveLoginInfo = true;

  void _showSecuritySnack(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seguridad: $title'),
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
          'Seguridad y permisos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Sección "Seguridad"
          _buildSectionTitle('Seguridad'),
          _buildSectionCard([
            _buildNavItem('Alertas de seguridad'),
            _buildDivider(),
            _buildNavItem('Verificación de seguridad'),
            _buildDivider(),
            _buildNavItem('Tus dispositivos'),
            _buildDivider(),
            _buildNavItem(
              'Verificación en dos pasos',
              trailingText: 'Desactivado',
            ),
            _buildDivider(),
            InkWell(
              onTap: () => setState(() => _saveLoginInfo = !_saveLoginInfo),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guardar los datos de inicio de sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicia sesión en gabriel_12343 en este dispositivo sin tener que introducir tus credenciales cada vez.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _saveLoginInfo,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF25F4EE),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[700],
                      onChanged: (value) {
                        setState(() => _saveLoginInfo = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildDivider(),
            _buildNavItem('Ayuda a tus amigos a recuperar sus cuentas'),
          ]),

          // Sección "Permisos"
          _buildSectionTitle('Permisos'),
          _buildSectionCard([
            _buildNavItem('Permisos de aplicaciones y servicios'),
            _buildDivider(),
            _buildNavItem('Ajustes del navegador'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
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

  Widget _buildNavItem(String title, {String? trailingText}) {
    return InkWell(
      onTap: () => _showSecuritySnack(title),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }
}