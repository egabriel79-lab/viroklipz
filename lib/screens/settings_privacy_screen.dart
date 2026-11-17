import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_account.dart';
import '../providers/auth_provider.dart';
import 'accessibility_settings_screen.dart';
import 'account_settings_screen.dart';
import 'activity_center_screen.dart';
import 'ads_settings_screen.dart';
import 'audience_control_screen.dart';
import 'balance_screen.dart';
import 'blocked_accounts_screen.dart';
import 'get_coins_screen.dart';
import 'clear_space_screen.dart';
import 'comments_settings_screen.dart';
import 'contacts_location_settings_screen.dart';
import 'content_preferences_screen.dart';
import 'data_saver_screen.dart';
import 'direct_messages_settings_screen.dart';
import 'display_settings_screen.dart';
import 'downloads_settings_screen.dart';
import 'family_sync_screen.dart';
import 'help_center_screen.dart';
import 'inbox_settings_screen.dart';
import 'language_settings_screen.dart';
import 'lite_mode_screen.dart';
import 'mentions_settings_screen.dart';
import 'music_settings_screen.dart';
import 'notifications_settings_screen.dart';
import 'offline_videos_screen.dart';
import 'playback_settings_screen.dart';
import 'privacy_audience_bottom_sheet.dart';
import 'privacy_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'private_account_screen.dart';
import 'reuse_content_screen.dart';
import 'security_permissions_screen.dart';
import 'share_profile_bottom_sheet.dart';
import 'switch_account_bottom_sheet.dart';
import 'terms_of_service_screen.dart';
import 'viewers_settings_screen.dart';
import 'wallpaper_settings_screen.dart';
import 'wellbeing_screen.dart';

class SettingsPrivacyScreen extends StatefulWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  State<SettingsPrivacyScreen> createState() => _SettingsPrivacyScreenState();
}

class _SettingsPrivacyScreenState extends State<SettingsPrivacyScreen> {
  String _followingListPrivacy = 'Solo tú';
  String _likedVideosPrivacy = 'Solo tú';

  void _showPlaceholderSnack(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajustes: $title'),
        backgroundColor: const Color(0xFF27272A),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openSwitchAccountSheet() {
    showSwitchAccountBottomSheet(context);
  }

  Future<void> _handleSignOut() async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final UserAccount? activeUser = auth.currentUser;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '¿Eliminar cuenta?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Esta acción es permanente y no se puede deshacer. Perderás todos tus videos, seguidores y mensajes.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE2C55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (activeUser != null) {
                  await auth.deleteAccount(activeUser);
                } else {
                  await auth.signOut();
                }
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/landing',
                  (route) => false,
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String activeAvatar = auth.currentUser?.avatarUrl ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop';
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
          'Ajustes y privacidad',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // 1. Actividad
          _buildSectionHeader('Actividad'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.folder_copy_outlined,
              title: 'Administrar publicaciones',
              onTap: () => _showPlaceholderSnack('Administrar publicaciones'),
            ),
            _buildSettingsItem(
              icon: Icons.auto_awesome_outlined,
              title: 'Preferencias de contenido',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContentPreferencesScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.live_tv_outlined,
              title: 'LIVE',
              onTap: () => _showPlaceholderSnack('LIVE'),
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notificaciones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.hourglass_bottom_outlined,
              title: 'Tiempo y bienestar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WellbeingScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.family_restroom_outlined,
              title: 'Sincronización familiar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilySyncScreen(),
                  ),
                );
              },
            ),
          ]),

          // 2. Cuenta
          _buildSectionHeader('Cuenta'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Cuenta',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Saldo',
              trailingText: '0.00 VES',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BalanceScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.monetization_on_outlined,
              title: 'Obtener Monedas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GetCoinsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.verified_user_outlined,
              title: 'Seguridad y permisos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityPermissionsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.share_outlined,
              title: 'Compartir el perfil',
              onTap: () => showShareProfileBottomSheet(context),
            ),
          ]),

          // 3. Visibilidad
          _buildSectionHeader('Visibilidad'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Cuenta privada',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivateAccountScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.block_outlined,
              title: 'Cuentas bloqueadas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlockedAccountsScreen(),
                  ),
                );
              },
            ),
          ]),

          // 4. Interacciones
          _buildSectionHeader('Interacciones'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.comment_outlined,
              title: 'Comentarios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommentsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.alternate_email,
              title: 'Menciones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MentionsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.send_outlined,
              title: 'Mensajes directos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DirectMessagesSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.repeat_rounded,
              title: 'Reutilizar contenido',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReuseContentScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.download_outlined,
              title: 'Descargas',
              trailingText: 'Activado',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.people_outline,
              title: 'Lista Siguiendo',
              trailingText: _followingListPrivacy,
              onTap: () {
                showPrivacyAudienceBottomSheet(
                  context: context,
                  title: 'Lista Siguiendo',
                  question: '¿Quién puede ver la lista de cuentas que sigues?',
                  footerNote:
                      'Solo las personas autorizadas podrán consultar los perfiles que sigues.',
                  currentValue: _followingListPrivacy,
                  onSelected: (val) =>
                      setState(() => _followingListPrivacy = val),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.favorite_border,
              title: 'Videos que te gustaron',
              trailingText: _likedVideosPrivacy,
              onTap: () {
                showPrivacyAudienceBottomSheet(
                  context: context,
                  title: 'Videos que te gustaron',
                  question:
                      'Permitir que los videos a los que diste me gusta sean visibles para',
                  footerNote:
                      'Incluso si esta lista es privada, los creadores pueden ver quién reaccionó a sus videos.',
                  currentValue: _likedVideosPrivacy,
                  onSelected: (val) =>
                      setState(() => _likedVideosPrivacy = val),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.visibility_outlined,
              title: 'Espectadores',
              trailingText: 'Activado',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewersSettingsScreen(),
                  ),
                );
              },
            ),
          ]),

          // 5. Contenido y pantalla
          _buildSectionHeader('Contenido y pantalla'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.music_note_outlined,
              title: 'Música',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MusicSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.chat_bubble_outline,
              title: 'Bandeja de entrada y mensajes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InboxSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.history,
              title: 'Centro de actividades',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityCenterScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.tune_outlined,
              title: 'Control del público',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AudienceControlScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.campaign_outlined,
              title: 'Anuncios',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdsSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.play_circle_outline,
              title: 'Reproducción',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaybackSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: 'Mostrar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplaySettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.language_outlined,
              title: 'Idiomas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.accessibility_new_outlined,
              title: 'Accesibilidad',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.contacts_outlined,
              title: 'Contactos y ubicación',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ContactsLocationSettingsScreen(),
                  ),
                );
              },
            ),
          ]),

          // 6. Caché y datos móviles
          _buildSectionHeader('Caché y datos móviles'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.cloud_download_outlined,
              title: 'Videos sin conexión',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineVideosScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.delete_outline,
              title: 'Liberar espacio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClearSpaceScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.data_saver_on_outlined,
              title: 'Ahorro de datos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataSaverScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.wallpaper_outlined,
              title: 'Fondo de pantalla',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WallpaperSettingsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.bolt_outlined,
              title: 'Modo lite',
              trailingText: 'Activado',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiteModeScreen(),
                  ),
                );
              },
            ),
          ]),

          // 7. Ayuda e información
          _buildSectionHeader('Ayuda e información'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Centro de privacidad',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: 'Términos y políticas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),
          ]),

          // 8. Inicio de sesión
          _buildSectionHeader('Inicio de sesión'),
          _buildSectionCard([
            _buildSettingsItem(
              icon: Icons.switch_account_outlined,
              title: 'Cambiar de cuenta',
              trailingWidget: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(activeAvatar),
              ),
              onTap: _openSwitchAccountSheet,
            ),
            _buildSettingsItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              isDestructive: true,
              onTap: _handleSignOut,
            ),
            _buildSettingsItem(
              icon: Icons.delete_forever_outlined,
              title: 'Eliminar cuenta',
              isDestructive: true,
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),

          const SizedBox(height: 28),
          Center(
            child: Text(
              'v47.7.3(202407030)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 8),
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

  // Widget reutilizable para cada ítem de Ajustes y privacidad
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final Color primaryColor =
        isDestructive ? Colors.redAccent : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}