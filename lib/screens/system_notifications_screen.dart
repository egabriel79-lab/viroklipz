import 'package:flutter/material.dart';

enum _SystemFilter { todo, viroklipz, creadores, transacciones }

class _SystemCardData {
  final String id;
  final _SystemFilter category;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String sender;
  final String timeAgo;
  final String title;
  final String subtitle;
  final String extraDetail;

  const _SystemCardData({
    required this.id,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.sender,
    required this.timeAgo,
    required this.title,
    required this.subtitle,
    required this.extraDetail,
  });
}

class SystemNotificationsScreen extends StatefulWidget {
  const SystemNotificationsScreen({super.key});

  @override
  State<SystemNotificationsScreen> createState() =>
      _SystemNotificationsScreenState();
}

class _SystemNotificationsScreenState extends State<SystemNotificationsScreen> {
  _SystemFilter _selectedFilter = _SystemFilter.todo;
  final Set<String> _expandedIds = <String>{};

  // Lista de tarjetas de la app (Viroklipz)
  static const List<_SystemCardData> _viroklipzCards = [
    _SystemCardData(
      id: 'sys-1',
      category: _SystemFilter.viroklipz,
      icon: Icons.music_note_rounded,
      iconColor: Color(0xFFFF2D55),
      iconBgColor: Color(0x33FF2D55),
      sender: 'Viroklipz · Actividades',
      timeAgo: '1 d',
      title:
          'Tus fans están buscando contenido. Asegúrate de que te encuentren.',
      subtitle:
          'Mira lo que es popular en tu nicho, respaldado por millones de búsquedas reales...',
      extraDetail:
          'Usa palabras clave claras en la descripción de tus videos verticales y aprovecha sonidos en tendencia para multiplicar tu alcance orgánico.',
    ),
    _SystemCardData(
      id: 'sys-4',
      category: _SystemFilter.viroklipz,
      icon: Icons.live_tv_rounded,
      iconColor: Color(0xFF25F4EE),
      iconBgColor: Color(0x3325F4EE),
      sender: 'LIVE · Actividades',
      timeAgo: '3 d',
      title: 'Tus espectadores quieren ver más de ti',
      subtitle:
          'Tu contenido LIVE genera comentarios. ¡Mantén el ritmo! LIVE Studio te permite iniciar...',
      extraDetail:
          'Conecta directamente con tus seguidores en tiempo real, responde preguntas de la comunidad y convierte los mejores momentos en clips.',
    ),
  ];

  // Lista de tarjetas de estadísticas y actualizaciones de creadores
  static const List<_SystemCardData> _creatorCards = [
    _SystemCardData(
      id: 'sys-2',
      category: _SystemFilter.creadores,
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFFFBBF24),
      iconBgColor: Color(0x33FBBF24),
      sender: 'Actualizaciones de creadores',
      timeAgo: '2 d',
      title: 'Hola, @mateo.cine, ¡la semana pasada te fue muy bien!',
      subtitle:
          '¿Estás ofreciendo lo que la gente busca? Descubre cómo te fue y obtén inspiración...',
      extraDetail:
          'Tus clips obtuvieron un 28% más de retención en los primeros 3 segundos. Publicar entre 7:00 PM y 9:00 PM mantiene el mejor ritmo.',
    ),
    _SystemCardData(
      id: 'sys-3',
      category: _SystemFilter.creadores,
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFFFBBF24),
      iconBgColor: Color(0x33FBBF24),
      sender: 'Actualizaciones de creadores',
      timeAgo: '10 mar',
      title: 'Perfecto para tu estilo creativo',
      subtitle:
          'activar monetización por vistas es un tema popular ahora. Explora tendencias relacionadas en Estadísticas de...',
      extraDetail:
          'Los creadores en tu categoría están generando un 35% más de ingresos activando la monetización en videos originales de más de 30 segundos.',
    ),
  ];

  // Lista de tarjetas de pagos y transacciones
  static const List<_SystemCardData> _transactionCards = [
    _SystemCardData(
      id: 'sys-5',
      category: _SystemFilter.transacciones,
      icon: Icons.attach_money_rounded,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF2563EB),
      sender: 'Asistente para transacciones',
      timeAgo: '2 ene',
      title: 'Límite de retirada actualizado',
      subtitle: 'Puedes retirar hasta \$100 al día en 01/2026.',
      extraDetail:
          'Tu cuenta cumple con los requisitos de verificación activa. Los retiros diarios se procesan automáticamente hacia tu método de pago.',
    ),
    _SystemCardData(
      id: 'sys-6',
      category: _SystemFilter.transacciones,
      icon: Icons.attach_money_rounded,
      iconColor: Colors.white,
      iconBgColor: Color(0xFF2563EB),
      sender: 'Asistente para transacciones',
      timeAgo: '19 dic 2025',
      title: 'Identidad verificada',
      subtitle: 'Tu identidad se verificó.',
      extraDetail:
          'Ya tienes acceso completo a retiros, propinas LIVE y herramientas de monetización para creadores en Viroklipz.',
    ),
  ];

  List<_SystemCardData> get _visibleCards {
    switch (_selectedFilter) {
      case _SystemFilter.todo:
        return [
          ..._viroklipzCards,
          ..._creatorCards,
          ..._transactionCards,
        ];
      case _SystemFilter.viroklipz:
        return _viroklipzCards;
      case _SystemFilter.creadores:
        return _creatorCards;
      case _SystemFilter.transacciones:
        return _transactionCards;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = _visibleCards;

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
        title: const Text(
          'Notificaciones del sistema',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferencias de notificaciones del sistema'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros deslizable horizontalmente
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip(_SystemFilter.todo, 'Todo'),
                const SizedBox(width: 8),
                _buildFilterChip(_SystemFilter.viroklipz, 'Viroklipz'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  _SystemFilter.creadores,
                  'Actualizaciones de creadores',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  _SystemFilter.transacciones,
                  'Asistente para transacciones',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          // Lista de tarjetas filtradas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildNotificationCard(cards[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(_SystemCardData card) {
    final isExpanded = _expandedIds.contains(card.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: icono + remitente + tiempo + menú (...)
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: card.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  card.icon,
                  size: 15,
                  color: card.iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.sender,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD4D4D8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                card.timeAgo,
                style: const TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opciones de ${card.sender}'),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFFA1A1AA),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Título principal en negrita y blanco
          Text(
            card.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          // Subtítulo en gris
          Text(
            card.subtitle,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0x1AFFFFFF)),
            const SizedBox(height: 10),
            Text(
              card.extraDetail,
              style: const TextStyle(
                color: Color(0xFFD4D4D8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Botón de texto "Ver más" en blanco
          TextButton(
            onPressed: () {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(card.id);
                } else {
                  _expandedIds.add(card.id);
                }
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isExpanded ? 'Ver menos' : 'Ver más',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(_SystemFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() => _selectedFilter = filter);
      },
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFF2D2D34),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}