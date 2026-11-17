import 'package:flutter/material.dart';

class ContactsLocationSettingsScreen extends StatefulWidget {
  const ContactsLocationSettingsScreen({super.key});

  @override
  State<ContactsLocationSettingsScreen> createState() =>
      _ContactsLocationSettingsScreenState();
}

class _ContactsLocationSettingsScreenState
    extends State<ContactsLocationSettingsScreen> {
  bool _contacts = true;
  bool _facebookFriends = true;
  bool _linkOpeners = true;
  bool _syncContacts = true;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          'Contactos y ubicación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Recomienda tu cuenta a otros'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _contacts,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Contactos',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _contacts = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _facebookFriends,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Amigos de Facebook',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _facebookFriends = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _linkOpeners,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Usuarios que abrieron o te enviaron enlaces',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  onChanged: (val) => setState(() => _linkOpeners = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Sincronizar contactos y amigos de Facebook'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _syncContacts,
              activeTrackColor: const Color(0xFFE91E63),
              title: const Text(
                'Sincronizar contactos',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Sube y sincroniza periódicamente tus contactos para encontrar amigos en Viroklipz.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _syncContacts = val),
            ),
          ),
        ],
      ),
    );
  }
}