import 'package:flutter/material.dart';

void showHowToWallpaperBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cómo establecer un fondo de pantalla',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text(
                    '1. Pulsa ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Icon(Icons.reply, color: Color(0xFFE91E63), size: 18),
                  Text(
                    ' en un video',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 110,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFE91E63),
                    child: Icon(Icons.reply, color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Text(
                    '2. Pulsa ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Icon(Icons.play_arrow, color: Color(0xFFFF5722), size: 20),
                  Expanded(
                    child: Text(
                      ' para establecer este video como fondo',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.group_add_outlined, color: Colors.white54),
                    Icon(Icons.bookmark_border, color: Colors.white54),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE91E63),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
                    ),
                    Icon(Icons.more_horiz, color: Colors.white54),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}