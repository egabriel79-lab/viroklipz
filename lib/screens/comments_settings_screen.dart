import 'package:flutter/material.dart';

class CommentsSettingsScreen extends StatefulWidget {
  const CommentsSettingsScreen({super.key});

  @override
  State<CommentsSettingsScreen> createState() => _CommentsSettingsScreenState();
}

class _CommentsSettingsScreenState extends State<CommentsSettingsScreen> {
  String _selectedAudience = 'everyone'; // 'everyone' | 'friends'
  bool _creatorControlMode = false;
  bool _filterSpam = true;

  void _openAudienceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'Comentarios',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black87),
                            onPressed: () => Navigator.pop(sheetContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Opción 1: Todo el mundo
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: const Color(0xFFFE2C55),
                      value: 'everyone',
                      groupValue: _selectedAudience,
                      title: const Text(
                        'Todo el mundo',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedAudience = val);
                        Navigator.pop(sheetContext);
                      },
                    ),

                    // Opción 2: Amigos 6 >
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: const Color(0xFFFE2C55),
                      value: 'friends',
                      groupValue: _selectedAudience,
                      title: Row(
                        children: const [
                          Text(
                            'Amigos 6',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black54,
                            size: 18,
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'Seguidores a los que también sigues',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedAudience = val);
                        Navigator.pop(sheetContext);
                      },
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
          'Comentarios',
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
          // Opción 1: Permite los comentarios desde
          InkWell(
            onTap: _openAudienceSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Permite los comentarios desde',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _selectedAudience == 'everyone'
                        ? 'Todo el m...'
                        : 'Amigos',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey[500], size: 20),
                ],
              ),
            ),
          ),

          // Sección "Filtros de comentarios"
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 22, bottom: 8),
            child: Text(
              'Filtros de comentarios',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Fila 1: Modo Control para creadores
                _buildFilterSwitchRow(
                  title: 'Modo Control para creadores',
                  subtitle:
                      'Activa esta opción para ocultar automáticamente comentarios ofensivos o poco relevantes hasta que decidas aprobarlos.',
                  value: _creatorControlMode,
                  onChanged: (v) => setState(() => _creatorControlMode = v),
                ),
                _buildDivider(),

                // Fila 2: Filtra comentarios no deseados
                _buildFilterSwitchRow(
                  title: 'Filtra comentarios no deseados',
                  subtitle:
                      'Oculta comentarios que el sistema detecte como spam o contenido inapropiado antes de mostrarse en tus videos.',
                  value: _filterSpam,
                  onChanged: (v) => setState(() => _filterSpam = v),
                ),
                _buildDivider(),

                // Fila 3: Filtra palabras clave específicas
                _buildFilterNavRow(
                  title: 'Filtra palabras clave específicas',
                  subtitle:
                      'Agrega palabras o frases que quieras ocultar automáticamente en los comentarios de todas tus publicaciones.',
                ),
                _buildDivider(),

                // Fila 4: Revisar comentarios filtrados
                _buildFilterNavRow(
                  title: 'Revisar comentarios filtrados',
                  subtitle: 'Se mostrarán solo los comentarios aprobados',
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

  Widget _buildFilterSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF25F4EE),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[700],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterNavRow({
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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