import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // Mapa de estado para todos los interruptores (todos en true salvo Tiempo en pantalla semanal)
  final Map<String, bool> _switchStates = {
    // Interacciones
    'likes': true,
    'saved_posts': true,
    'comments': true,
    'new_followers': true,
    'profile_views': true,
    'reposts': true,
    'interacted_posts': true,
    'streaks': true,
    // Mensajes
    'direct_messages': true,
    'dm_previews': true,
    'message_requests': true,
    'activity_status': true,
    // Boletín de noticias
    'new_bulletins': true,
    'bulletin_invites': true,
    'bulletin_interactions': true,
    'bulletin_new_members': true,
    // Sugerencias de publicaciones personalizadas
    'posts_people_you_may_know': true,
    'shared_by_others': true,
    'posts_you_might_like': true,
    // LIVE
    'live_creator_rankings': true,
    // Tiempo en pantalla (único en false por defecto)
    'weekly_screen_time': false,
    // Otro
    'people_you_may_know': true,
    'personalized_updates': true,
    'other_accounts_notifications': true,
  };

  void _showNavFeedback(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo: $title'),
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
          'Notificaciones',
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
          // 1. Sección Superior (Sin título)
          _buildSectionCard([
            _buildNavigationTile(
              'Notificaciones en la aplicación',
              null,
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Horario de notificaciones push',
              'Establece un horario para desactivar las notificaciones push.',
            ),
          ]),

          // 2. Sección "Interacciones"
          _buildSectionTitle('Interacciones'),
          _buildSectionCard([
            _buildSwitchTile('Me gusta', null, 'likes'),
            _buildDivider(),
            _buildSwitchTile('Publicaciones guardadas', null, 'saved_posts'),
            _buildDivider(),
            _buildSwitchTile('Comentarios', null, 'comments'),
            _buildDivider(),
            _buildSwitchTile('Nuevos seguidores', null, 'new_followers'),
            _buildDivider(),
            _buildSwitchTile(
              'Visualizaciones del perfil',
              null,
              'profile_views',
            ),
            _buildDivider(),
            _buildSwitchTile('Publicaciones compartidas', null, 'reposts'),
            _buildDivider(),
            _buildSwitchTile(
              'Publicaciones con las que interactuaste',
              'Recibe notificaciones sobre publicaciones que te gustaron, comentaste o compartiste recientemente.',
              'interacted_posts',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Rachas',
              'Recibe notificaciones cuando estés a punto de perder una racha de chat con tus amigos.',
              'streaks',
            ),
          ]),

          // 3. Sección "Mensajes"
          _buildSectionTitle('Mensajes'),
          _buildSectionCard([
            _buildSwitchTile('Mensajes directos', null, 'direct_messages'),
            _buildDivider(),
            _buildNavigationTile(
              'Llamadas de voz',
              'Personas a las que sigues',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Vista previa de mensajes directos',
              null,
              'dm_previews',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Solicitudes de mensajes',
              'Recibe una notificación cuando alguien te envíe una solicitud de mensaje.',
              'message_requests',
            ),
            _buildDivider(),
            _buildSwitchTile('Estado de actividad', null, 'activity_status'),
            _buildDivider(),
            _buildNavigationTile(
              'Tonos de alerta',
              'Establece tonos de alerta únicos para tus notificaciones de mensajes.',
            ),
          ]),

          // 4. Sección "Boletín de noticias"
          _buildSectionTitle('Boletín de noticias'),
          _buildSectionCard([
            _buildSwitchTile('Boletines nuevos', null, 'new_bulletins'),
            _buildDivider(),
            _buildSwitchTile('Invitaciones', null, 'bulletin_invites'),
            _buildDivider(),
            _buildSwitchTile(
              'Interacciones',
              null,
              'bulletin_interactions',
            ),
            _buildDivider(),
            _buildSwitchTile('Nuevos miembros', null, 'bulletin_new_members'),
          ]),

          // 5. Sección "Sugerencias de publicaciones"
          _buildSectionTitle('Sugerencias de publicaciones'),
          _buildSectionCard([
            _buildNavigationTile(
              'Publicaciones de cuentas que sigues',
              null,
            ),
          ]),

          // 6. Sección "Sugerencias de publicaciones personalizadas"
          _buildSectionTitle('Sugerencias de publicaciones personalizadas'),
          _buildSectionCard([
            _buildSwitchTile(
              'Publicaciones de gente que quizás conozcas',
              null,
              'posts_people_you_may_know',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Compartidas por otros',
              null,
              'shared_by_others',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Publicaciones que podrían gustarte',
              null,
              'posts_you_might_like',
            ),
          ]),

          // 7. Sección "LIVE"
          _buildSectionTitle('LIVE'),
          _buildSectionCard([
            _buildNavigationTile('Ajustes de notificaciones de LIVE', null),
            _buildDivider(),
            _buildSwitchTile(
              'Notificaciones de los rankings de creadores',
              'Activa esta opción para recibir notificaciones sobre actualizaciones y logros de los rankings de creadores.',
              'live_creator_rankings',
            ),
          ]),

          // 8. Sección "Tiempo en pantalla"
          _buildSectionTitle('Tiempo en pantalla'),
          _buildSectionCard([
            _buildSwitchTile(
              'Novedades sobre el tiempo en pantalla semanal',
              null,
              'weekly_screen_time',
            ),
          ]),

          // 9. Sección "Otro"
          _buildSectionTitle('Otro'),
          _buildSectionCard([
            _buildSwitchTile(
              'Personas que quizás conozcas',
              'Estas son las notificaciones sobre cuentas sugeridas de personas que podrías conocer.',
              'people_you_may_know',
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Actualizaciones personalizadas y más',
              null,
              'personalized_updates',
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Notificaciones por correo electrónico',
              null,
            ),
            _buildDivider(),
            _buildNavigationTile('Notificaciones por SMS', null),
            _buildDivider(),
            _buildSwitchTile(
              'Notificaciones de tus otras cuentas de TikTok',
              null,
              'other_accounts_notifications',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
    );
  }

  // Widget reutilizable para ítems con Switch
  Widget _buildSwitchTile(String title, String? subtitle, String id) {
    final bool isActive = _switchStates[id] ?? true;

    return InkWell(
      onTap: () => setState(() => _switchStates[id] = !isActive),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  if (subtitle != null) ...[
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
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: isActive,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF25F4EE),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[700],
              onChanged: (value) {
                setState(() => _switchStates[id] = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para ítems con flecha '>'
  Widget _buildNavigationTile(String title, String? subtitle) {
    return InkWell(
      onTap: () => _showNavFeedback(title),
      borderRadius: BorderRadius.circular(12),
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
                  if (subtitle != null) ...[
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