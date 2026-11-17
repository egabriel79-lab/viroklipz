import 'package:flutter/material.dart';

class CommentHistoryScreen extends StatefulWidget {
  const CommentHistoryScreen({super.key});

  @override
  State<CommentHistoryScreen> createState() => _CommentHistoryScreenState();
}

class _CommentHistoryScreenState extends State<CommentHistoryScreen> {
  String _selectedOrder = 'De más recientes a más antiguos';

  final List<String> _orderOptions = const [
    'De más recientes a más antiguos',
    'De más antiguos a más recientes',
  ];

  final List<Map<String, String>> _comments = const [
    {
      'user': 'Eloy',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
      'comment': '[Sticker]',
      'date': '13 nov',
      'videoThumb':
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=300&auto=format&fit=crop',
    },
    {
      'user': 'Eloy',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
      'comment': '¡Qué transición tan brutal! 🔥',
      'date': '11 nov',
      'videoThumb':
          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=300&auto=format&fit=crop',
    },
    {
      'user': 'Eloy',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
      'comment': '¿Cómo se llama este audio?',
      'date': '8 nov',
      'videoThumb':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&auto=format&fit=crop',
    },
    {
      'user': 'Eloy',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
      'comment': 'Guardado para grabarlo el finde 🙌',
      'date': '4 nov',
      'videoThumb':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300&auto=format&fit=crop',
    },
    {
      'user': 'Eloy',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop',
      'comment': 'Me encantó la iluminación 35mm 📸',
      'date': '29 oct',
      'videoThumb':
          'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=300&auto=format&fit=crop',
    },
  ];

  void _openSortBottomSheet() {
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Ordenar por',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  ..._orderOptions.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue: _selectedOrder,
                      activeColor: const Color(0xFFFF2D55),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {});
                        setState(() => _selectedOrder = value);
                        Navigator.pop(sheetContext);
                      },
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
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
    final List<Map<String, String>> orderedComments =
        _selectedOrder == 'De más recientes a más antiguos'
            ? _comments
            : _comments.reversed.toList();

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
          'Historial de comentarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chip / píldora alineado a la izquierda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: ActionChip(
              onPressed: _openSortBottomSheet,
              backgroundColor: const Color(0xFF1E1E22),
              side: const BorderSide(color: Colors.white12),
              shape: const StadiumBorder(),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedOrder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

          // Lista de comentarios
          Expanded(
            child: ListView.builder(
              itemCount: orderedComments.length,
              itemBuilder: (context, index) {
                final item = orderedComments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: NetworkImage(item['avatar']!),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['user']!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item['comment']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['date']!,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['videoThumb']!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
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