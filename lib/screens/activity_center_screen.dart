import 'package:flutter/material.dart';
import 'account_history_screen.dart';
import 'ad_activity_history_screen.dart';
import 'comment_history_screen.dart';
import 'content_reuse_history_screen.dart';
import 'mention_history_screen.dart';
import 'search_history_screen.dart';
import 'video_history_screen.dart';

class ActivityCenterScreen extends StatelessWidget {
  const ActivityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Centro de actividades',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.play_circle_outline,
              color: Colors.white70,
              size: 24,
            ),
            title: 'Historial de videos vistos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white70,
              size: 22,
            ),
            title: 'Historial de comentarios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommentHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.search,
              color: Colors.white70,
              size: 24,
            ),
            title: 'Historial de búsqueda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: Container(
              width: 24,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: 'Historial de actividad publicitaria',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdActivityHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.alternate_email,
              color: Colors.white70,
              size: 22,
            ),
            title: 'Historial de menciones',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MentionHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.person_outline,
              color: Colors.white70,
              size: 24,
            ),
            title: 'Historial de la cuenta',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            leading: const Icon(
              Icons.repeat_rounded,
              color: Colors.white70,
              size: 24,
            ),
            title: 'Historial de reutilización de contenido',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContentReuseHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required Widget leading,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: SizedBox(width: 28, child: Center(child: leading)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}