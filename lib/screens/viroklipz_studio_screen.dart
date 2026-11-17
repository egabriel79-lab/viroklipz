import 'package:flutter/material.dart';

class ViroklipzStudioScreen extends StatefulWidget {
  const ViroklipzStudioScreen({super.key});

  @override
  State<ViroklipzStudioScreen> createState() => _ViroklipzStudioScreenState();
}

class _ViroklipzStudioScreenState extends State<ViroklipzStudioScreen> {
  bool _is28Days = false;

  @override
  Widget build(BuildContext context) {
    final views = _is28Days ? '62.4K' : '14.8K';
    final visits = _is28Days ? '7.3K' : '1.9K';
    final likes = _is28Days ? '2.4K' : '577';
    final followers = _is28Days ? '+194' : '+48';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.pink, size: 18),
            SizedBox(width: 6),
            Text(
              'Viroklipz Studio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de creador',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _is28Days
                        ? '+39% vs mes anterior'
                        : '+24% vs semana anterior',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ToggleButtons(
                isSelected: [!_is28Days, _is28Days],
                onPressed: (index) => setState(() => _is28Days = index == 1),
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.black,
                color: Colors.white70,
                fillColor: Colors.white,
                constraints: const BoxConstraints(minHeight: 32, minWidth: 64),
                children: const [
                  Text('7 días', style: TextStyle(fontSize: 12)),
                  Text('28 días', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _buildMetricCard('Visualizaciones', views, Icons.visibility_outlined, const Color(0xFF25F4EE)),
              _buildMetricCard('Visitas al perfil', visits, Icons.people_outline, const Color(0xFFFF2D55)),
              _buildMetricCard('Me gusta', likes, Icons.favorite_border, const Color(0xFFF43F5E)),
              _buildMetricCard('Seguidores', followers, Icons.trending_up, const Color(0xFF34D399)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.pink.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF2563EB),
                      child: Icon(Icons.attach_money, color: Colors.white, size: 16),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Programa de Creadores',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Monetización por vistas',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.74,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF2D55)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '7,400 / 10,000 reproducciones elegibles este mes',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}