import 'package:flutter/material.dart';

class ContentPreferencesScreen extends StatefulWidget {
  const ContentPreferencesScreen({super.key});

  @override
  State<ContentPreferencesScreen> createState() =>
      _ContentPreferencesScreenState();
}

class _ContentPreferencesScreenState extends State<ContentPreferencesScreen> {
  bool _restrictedMode = false;
  bool _stemFeed = false;

  void _showOptionSnack(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        backgroundColor: const Color(0xFF27272A),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openModeBottomSheet({
    required String title,
    required String description,
    required String switchLabel,
    required bool currentValue,
    required ValueChanged<bool> onSave,
  }) {
    bool draftValue = currentValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                switchLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                draftValue ? 'Activada' : 'Desactivada',
                                style: TextStyle(
                                  color: draftValue
                                      ? const Color(0xFFFE2C55)
                                      : Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: draftValue,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFFFE2C55),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey[700],
                            onChanged: (val) {
                              setModalState(() => draftValue = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onSave(draftValue);
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE2C55),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
          'Preferencias de contenido',
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
          // Grupo 1: Filtros y modos
          _buildGroupCard([
            _buildPreferenceItem(
              icon: Icons.filter_alt_outlined,
              title: 'Filtrar por palabras clave',
              trailingText: '0',
              onTap: () => _showOptionSnack('Filtrar por palabras clave'),
            ),
            _buildDivider(),
            _buildPreferenceItem(
              icon: Icons.verified_user_outlined,
              title: 'Modo Restringido',
              trailingText: _restrictedMode ? 'Activada' : 'Desactivada',
              isActive: _restrictedMode,
              onTap: () {
                _openModeBottomSheet(
                  title: 'Modo Restringido',
                  description:
                      'Limita la aparición de videos que pueden no ser apropiados para todos los públicos.',
                  switchLabel: 'Activar Modo Restringido',
                  currentValue: _restrictedMode,
                  onSave: (val) => setState(() => _restrictedMode = val),
                );
              },
            ),
            _buildDivider(),
            _buildPreferenceItem(
              icon: Icons.science_outlined,
              title: 'Feed STEM',
              trailingText: _stemFeed ? 'Activada' : 'Desactivada',
              isActive: _stemFeed,
              onTap: () {
                _openModeBottomSheet(
                  title: 'Feed STEM',
                  description:
                      'Agrega una pestaña dedicada a Ciencia, Tecnología, Ingeniería y Matemáticas.',
                  switchLabel: 'Mostrar Feed STEM',
                  currentValue: _stemFeed,
                  onSave: (val) => setState(() => _stemFeed = val),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),

          // Grupo 2: Personalización del feed
          _buildGroupCard([
            _buildPreferenceItem(
              icon: Icons.tune_outlined,
              title: 'Gestionar temas',
              onTap: () => _showOptionSnack('Gestionar temas'),
            ),
            _buildDivider(),
            _buildPreferenceItem(
              icon: Icons.refresh_rounded,
              title: 'Actualiza tu feed Para ti',
              onTap: () => _showOptionSnack('Actualiza tu feed Para ti'),
            ),
          ]),
          const SizedBox(height: 16),

          // Grupo 3: Cuentas silenciadas
          _buildGroupCard([
            _buildPreferenceItem(
              icon: Icons.volume_off_outlined,
              title: 'Cuentas silenciadas',
              onTap: () => _showOptionSnack('Cuentas silenciadas'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
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
      indent: 50,
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    String? trailingText,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
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
                style: TextStyle(
                  color: isActive ? const Color(0xFFFE2C55) : Colors.grey[400],
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
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