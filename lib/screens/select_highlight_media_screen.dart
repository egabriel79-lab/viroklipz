import 'package:flutter/material.dart';

class HighlightStoryData {
  final String title;
  final String coverUrl;
  final List<String> slides;

  const HighlightStoryData({
    required this.title,
    required this.coverUrl,
    required this.slides,
  });
}

class SelectHighlightMediaScreen extends StatefulWidget {
  const SelectHighlightMediaScreen({super.key});

  @override
  State<SelectHighlightMediaScreen> createState() =>
      _SelectHighlightMediaScreenState();
}

class _SelectHighlightMediaScreenState
    extends State<SelectHighlightMediaScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Destacado');

  final List<String> _galleryUrls = const [
    'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop',
  ];

  final List<int> _selectedIndices = [0];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleIndex(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _confirmSelection() {
    if (_selectedIndices.isEmpty) return;
    final List<String> picked =
        _selectedIndices.map((idx) => _galleryUrls[idx]).toList();
    final String cleanTitle = _titleController.text.trim();

    Navigator.pop(
      context,
      HighlightStoryData(
        title: cleanTitle.isEmpty ? 'Destacado' : cleanTitle,
        coverUrl: picked.first,
        slides: picked,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nuevo destacado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _selectedIndices.isEmpty ? null : _confirmSelection,
              style: TextButton.styleFrom(
                backgroundColor: _selectedIndices.isEmpty
                    ? Colors.white12
                    : const Color(0xFFFF2D55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              child: Text(
                'Listo (${_selectedIndices.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _titleController,
              maxLength: 18,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Nombre del destacado',
                labelStyle: const TextStyle(color: Colors.white54),
                counterText: '',
                filled: true,
                fillColor: const Color(0xFF1B1B1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 9 / 16,
              ),
              itemCount: _galleryUrls.length,
              itemBuilder: (context, index) {
                final int order = _selectedIndices.indexOf(index);
                final bool isSelected = order != -1;
                return GestureDetector(
                  onTap: () => _toggleIndex(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_galleryUrls[index], fit: BoxFit.cover),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFF2D55),
                              width: 2.5,
                            ),
                            color: Colors.black26,
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelected
                              ? const Color(0xFFFF2D55)
                              : Colors.black45,
                          child: Text(
                            isSelected ? '${order + 1}' : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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