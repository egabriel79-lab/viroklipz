import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

void showShareProfileBottomSheet(
  BuildContext context, {
  String handle = 'gabriel_12343',
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => ShareProfileBottomSheet(handle: handle),
  );
}

class ShareProfileBottomSheet extends StatelessWidget {
  final String handle;

  const ShareProfileBottomSheet({
    super.key,
    this.handle = 'gabriel_12343',
  });

  static const List<Map<String, String>> _contacts = [
    {
      'name': 'la toxica #1🦋',
      'avatar':
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&auto=format&fit=crop',
    },
    {
      'name': '1382jovana',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
    },
    {
      'name': 'Tarot Masónico',
      'avatar':
          'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=200&auto=format&fit=crop',
    },
    {
      'name': 'ELOY',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
    },
  ];

  String get _profileUrl => 'https://viroklipz.app/@$handle';

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _profileUrl));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        backgroundColor: Color(0xFF27272A),
      ),
    );
  }

  Future<void> _shareExternal(BuildContext context) async {
    Navigator.pop(context);
    await Share.share('¡Mira mi perfil en Viroklipz! $_profileUrl');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador superior
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Encabezado: Lupa (izq), "Enviar a" (centro), X (der)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black87),
                  onPressed: () {},
                ),
                const Text(
                  'Enviar a',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fila 1: Scroll horizontal de avatares con nombres
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _contacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Perfil enviado a ${contact['name']}',
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 68,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(contact['avatar']!),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            contact['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 24),

            // Fila 2: Botones de acción (Copiar enlace, WhatsApp, Facebook, Telegram, SMS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareAction(
                  label: 'Copiar enlace',
                  icon: Icons.link,
                  bgColor: Colors.grey[200]!,
                  iconColor: Colors.black87,
                  onTap: () => _copyLink(context),
                ),
                _buildShareAction(
                  label: 'WhatsApp',
                  icon: Icons.chat,
                  bgColor: const Color(0xFF25D366),
                  iconColor: Colors.white,
                  onTap: () => _shareExternal(context),
                ),
                _buildShareAction(
                  label: 'Facebook',
                  icon: Icons.facebook,
                  bgColor: const Color(0xFF1877F2),
                  iconColor: Colors.white,
                  onTap: () => _shareExternal(context),
                ),
                _buildShareAction(
                  label: 'Telegram',
                  icon: Icons.send,
                  bgColor: const Color(0xFF229ED9),
                  iconColor: Colors.white,
                  onTap: () => _shareExternal(context),
                ),
                _buildShareAction(
                  label: 'SMS',
                  icon: Icons.sms_outlined,
                  bgColor: const Color(0xFF1E3A8A),
                  iconColor: Colors.white,
                  onTap: () => _shareExternal(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareAction({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}