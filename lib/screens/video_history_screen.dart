import 'package:flutter/material.dart';

class VideoHistoryScreen extends StatefulWidget {
  const VideoHistoryScreen({super.key});

  @override
  State<VideoHistoryScreen> createState() => _VideoHistoryScreenState();
}

class _VideoHistoryScreenState extends State<VideoHistoryScreen> {
  String _selectedDateFilter = 'Cualquier fecha';

  final List<String> _dateOptions = const [
    'Cualquier fecha',
    'Ayer',
    'Semana pasada',
    'Último mes',
    'Rango de fechas',
  ];

  final List<Map<String, String>> _watchedVideos = const [
    {
      'thumb':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400&auto=format&fit=crop',
      'views': '1.6M',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=400&auto=format&fit=crop',
      'views': '842K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&auto=format&fit=crop',
      'views': '215K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&auto=format&fit=crop',
      'views': '94.2K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&auto=format&fit=crop',
      'views': '310K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=400&auto=format&fit=crop',
      'views': '1.1M',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400&auto=format&fit=crop',
      'views': '56.8K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=400&auto=format&fit=crop',
      'views': '429K',
    },
    {
      'thumb':
          'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&auto=format&fit=crop',
      'views': '712K',
    },
  ];

  void _openDateFilterSheet() {
    String tempSelected = _selectedDateFilter;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const Text(
                          'Filtrar por fecha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedDateFilter = tempSelected);
                            Navigator.pop(sheetContext);
                          },
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(
                              color: Color(0xFFFF2D55),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  ..._dateOptions.map((option) {
                    final bool isRange = option == 'Rango de fechas';
                    return RadioListTile<String>(
                      value: option,
                      groupValue: tempSelected,
                      activeColor: const Color(0xFFFF2D55),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => tempSelected = value);
                        }
                      },
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      secondary: isRange
                          ? const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            )
                          : null,
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
        title: const Text(
          'Historial de videos vistos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chip "Filtrar por fecha ⌄"
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: ActionChip(
              onPressed: _openDateFilterSheet,
              backgroundColor: const Color(0xFF1E1E22),
              side: const BorderSide(color: Colors.white12),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedDateFilter == 'Cualquier fecha'
                        ? 'Filtrar por fecha'
                        : _selectedDateFilter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Título de sección "Hoy"
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text(
              _selectedDateFilter == 'Cualquier fecha'
                  ? 'Hoy'
                  : _selectedDateFilter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // GridView.builder de 3 columnas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 9 / 16,
              ),
              itemCount: _watchedVideos.length,
              itemBuilder: (context, index) {
                final item = _watchedVideos[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(item['thumb']!, fit: BoxFit.cover),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item['views']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}