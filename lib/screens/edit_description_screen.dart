import 'package:flutter/material.dart';

class EditDescriptionScreen extends StatefulWidget {
  final String initialDescription;

  const EditDescriptionScreen({
    super.key,
    this.initialDescription = '',
  });

  @override
  State<EditDescriptionScreen> createState() => _EditDescriptionScreenState();
}

class _EditDescriptionScreenState extends State<EditDescriptionScreen> {
  static const int _maxLength = 80;
  late final TextEditingController _controller;

  static const List<String> _quickTags = [
    '🎬 Creador de clips',
    '🎵 Música & beats',
    '✈️ Viajes y rutas',
    '📸 Fotografía 35mm',
    '🎮 Gaming',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendTag(String tag) {
    final current = _controller.text.trim();
    final next = current.isEmpty ? tag : '$current · $tag';
    if (next.length <= _maxLength) {
      setState(() {
        _controller.text = next;
        _controller.selection = TextSelection.collapsed(offset: next.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 92,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Descripción',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_controller.text.trim());
            },
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Color(0xFFFF2D55),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TU PRESENTACIÓN',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLength: _maxLength,
              maxLines: 4,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Agrega una descripción sobre ti o tus aficiones...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ideas rápidas',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTags.map((tag) {
                return ActionChip(
                  label: Text(
                    tag,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                  onPressed: () => _appendTag(tag),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}