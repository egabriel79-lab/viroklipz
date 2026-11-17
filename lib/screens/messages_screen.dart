import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'chat_screen.dart';
import 'system_notifications_screen.dart';

class _ChatItemData {
  final String chatId;
  final String otherUserId;
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final String initials;
  final bool showCameraIcon;

  const _ChatItemData({
    required this.chatId,
    required this.otherUserId,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    required this.initials,
    this.showCameraIcon = false,
  });
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const List<_ChatItemData> _mockChats = [
    _ChatItemData(
      chatId: 'chat_bicorne',
      otherUserId: 'uid_bicorne',
      name: 'El Bicorne',
      lastMessage: 'As Salam aleykum...',
      time: '5 nov',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop',
      initials: 'EB',
      showCameraIcon: true,
    ),
    _ChatItemData(
      chatId: 'chat_toxica',
      otherUserId: 'uid_toxica',
      name: 'la toxica #1🦋',
      lastMessage: 'Enviado',
      time: '10:30 AM',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop',
      initials: 'LT',
      showCameraIcon: true,
    ),
    _ChatItemData(
      chatId: 'chat_jovana',
      otherUserId: 'uid_jovana',
      name: '1382jovana🇻🇪',
      lastMessage: 'Hola, ¿cómo estás?',
      time: 'Ayer',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop',
      initials: '13',
      showCameraIcon: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // A. SECCIÓN DE SISTEMA (Arriba de todo)
          _SystemTile(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFFF2D55),
            circleColor: const Color(0xFFFF2D55).withValues(alpha: 0.18),
            title: 'Actividad y nuevos seguidores',
            subtitle: 'Tienes nuevas visitas en tu perfil',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActivityScreen()),
              );
            },
          ),
          _SystemTile(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF25F4EE),
            circleColor: const Color(0xFF25F4EE).withValues(alpha: 0.14),
            title: 'Notificación del sistema',
            subtitle: 'Bienvenido a Viroklipz. ¡Sube tu primer video!',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SystemNotificationsScreen(),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          // B. SECCIÓN DE MENSAJES ENTRE USUARIOS
          ..._mockChats.map(
            (chat) => _UserChatTile(
              chat: chat,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chat.chatId,
                      otherUserId: chat.otherUserId,
                      otherUserName: chat.name,
                      otherUserAvatarUrl: chat.avatarUrl,
                      otherUserInitials: chat.initials,
                    ),
                  ),
                );
              },
              onCameraTap: () => _showSnack(
                context,
                'Enviar video rápido a ${chat.name}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1F23),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SystemTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SystemTile({
    required this.icon,
    required this.iconColor,
    required this.circleColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 13,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF71717A),
        size: 20,
      ),
    );
  }
}

class _UserChatTile extends StatelessWidget {
  final _ChatItemData chat;
  final VoidCallback onTap;
  final VoidCallback onCameraTap;

  const _UserChatTile({
    required this.chat,
    required this.onTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  chat.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF27272A),
                    alignment: Alignment.center,
                    child: Text(
                      chat.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.time,
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 11.5,
                  ),
                ),
                if (chat.showCameraIcon) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onCameraTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFFA1A1AA),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}