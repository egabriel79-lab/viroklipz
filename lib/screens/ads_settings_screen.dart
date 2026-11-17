import 'package:flutter/material.dart';

class AdsSettingsScreen extends StatefulWidget {
  const AdsSettingsScreen({super.key});

  @override
  State<AdsSettingsScreen> createState() => _AdsSettingsScreenState();
}

class _AdsSettingsScreenState extends State<AdsSettingsScreen> {
  bool _offAppTargetedAds = true;
  bool _personalizedAds = true;

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
          'Plan y anuncios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Administra los anuncios que ves',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Gestionar los temas de los anuncios',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Elige los intereses y categorías de anuncios que prefieres ver.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Modificar los datos personales',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Actualiza cómo se utiliza tu perfil para personalizar promociones.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Silenciar anunciantes',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Silencia marcas específicas cuyos anuncios no deseas ver.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Administra tus datos fuera de Viroklipz',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _offAppTargetedAds,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Anuncios dirigidos fuera de Viroklipz',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Los anunciantes pueden mostrar promociones basadas en tu actividad fuera de la plataforma.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) =>
                      setState(() => _offAppTargetedAds = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                SwitchListTile(
                  value: _personalizedAds,
                  activeTrackColor: const Color(0xFFE91E63),
                  title: const Text(
                    'Anuncios personalizados',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Usa tus intereses y actividad en Viroklipz para mostrar anuncios más relevantes.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  onChanged: (val) => setState(() => _personalizedAds = val),
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Desconectar anunciantes',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  title: const Text(
                    'Borrar datos de actividad fuera de Viroklipz',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[500]),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}