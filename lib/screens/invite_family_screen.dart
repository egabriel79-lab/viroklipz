import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteFamilyScreen extends StatefulWidget {
  final bool isGuardian;

  const InviteFamilyScreen({
    super.key,
    required this.isGuardian,
  });

  @override
  State<InviteFamilyScreen> createState() => _InviteFamilyScreenState();
}

class _InviteFamilyScreenState extends State<InviteFamilyScreen> {
  final TextEditingController _searchController = TextEditingController();

  String get _inviteUrl => widget.isGuardian
      ? 'https://viroklipz.app/family-sync/invite-teen-7841'
      : 'https://viroklipz.app/family-sync/invite-guardian-7841';

  Future<void> _copyInviteLink() async {
    await Clipboard.setData(ClipboardData(text: _inviteUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace de invitación copiado'),
        backgroundColor: Color(0xFF27272A),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = widget.isGuardian
        ? 'Invita a tu adolescente'
        : 'Invita a tu tutor legal';

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
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Texto explicativo en gris
          Text(
            widget.isGuardian
                ? 'Envía una invitación directa o muestra este código QR para vincular la cuenta de tu adolescente con tu perfil.'
                : 'Envía una invitación directa o comparte este código QR con tu tutor legal para activar la Sincronización familiar.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Sección de compartir
          InkWell(
            onTap: _copyInviteLink,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Compartir enlace...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildShareCircle(
                    icon: Icons.link,
                    color: Colors.lightBlue,
                    onTap: _copyInviteLink,
                  ),
                  const SizedBox(width: 8),
                  _buildShareCircle(
                    icon: Icons.chat,
                    color: Colors.green,
                    onTap: _copyInviteLink,
                  ),
                  const SizedBox(width: 8),
                  _buildShareCircle(
                    icon: Icons.sms_outlined,
                    color: Colors.blueAccent,
                    onTap: _copyInviteLink,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[500], size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sección QR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Escanear o mostrar código QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      QrImageView(
                        data: _inviteUrl,
                        version: QrVersions.auto,
                        size: 190,
                        backgroundColor: Colors.white,
                      ),
                      // Logo de Viroklipz en el centro
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF25F4EE),
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isGuardian
                      ? 'Pídele al adolescente que escanee este código QR. Este código expirará el 21 nov.'
                      : 'Pídele a tu tutor legal que escanee este código QR. Este código expirará el 21 nov.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 17,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}