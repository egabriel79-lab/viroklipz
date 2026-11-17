import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'camera_screen.dart';
import 'feed_screen.dart';
import 'friends_feed_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0 = Inicio, 1 = Comunidad, 2 = Mensajes, 3 = Perfil
  bool _isCreateOpen = false;

  Future<void> _openCamera() async {
    setState(() => _isCreateOpen = true);

    final bool? published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const CameraScreen(),
      ),
    );

    if (!mounted) return;
    setState(() {
      _isCreateOpen = false;
      if (published == true) {
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FeedScreen(
            isFeedVisible: _selectedIndex == 0 && !_isCreateOpen,
            onOpenCamera: _openCamera,
          ),
          FriendsFeedScreen(
            isFeedVisible: _selectedIndex == 1 && !_isCreateOpen,
            onOpenCamera: _openCamera,
          ),
          const MessagesScreen(),
          const ProfileScreen(embeddedInMainShell: true),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.background,
        padding: EdgeInsets.zero,
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Inicio', 0),
            _buildNavItem(Icons.people_outline, 'Comunidad', 1),
            GestureDetector(
              onTap: _openCamera,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.55),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AppColors.magenta.withValues(alpha: 0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            _buildNavItem(Icons.chat_bubble_outline, 'Mensajes', 2),
            _buildNavItem(Icons.person_outline, 'Perfil', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color itemColor = isSelected ? AppColors.orange : Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: itemColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}