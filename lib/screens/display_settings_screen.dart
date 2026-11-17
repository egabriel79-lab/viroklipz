import 'package:flutter/material.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  String _selectedTheme = 'oscuro';
  bool _useDeviceSettings = false;

  Widget _buildThemeMockup({
    required String id,
    required String label,
    required bool isDarkPreview,
  }) {
    final bool selected = _selectedTheme == id;
    const Color pinkAccent = Color(0xFFE91E63);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = id),
        child: Column(
          children: [
            Container(
              height: 132,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkPreview
                    ? const Color(0xFF141416)
                    : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? pinkAccent : Colors.white12,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkPreview
                              ? Colors.white24
                              : Colors.black12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDarkPreview
                                ? Colors.white24
                                : Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkPreview
                            ? const Color(0xFF27272A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: pinkAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedTheme,
              activeColor: pinkAccent,
              onChanged: (val) {
                if (val != null) setState(() => _selectedTheme = val);
              },
            ),
          ],
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
          'Mostrar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Aspecto',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildThemeMockup(
                  id: 'claro',
                  label: 'Claro',
                  isDarkPreview: false,
                ),
                const SizedBox(width: 16),
                _buildThemeMockup(
                  id: 'oscuro',
                  label: 'Oscuro',
                  isDarkPreview: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _useDeviceSettings,
              activeTrackColor: const Color(0xFFE91E63),
              title: const Text(
                'Usar ajustes del dispositivo',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              subtitle: Text(
                'Adapta automáticamente el aspecto de Viroklipz al tema de tu teléfono.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onChanged: (val) => setState(() => _useDeviceSettings = val),
            ),
          ),
        ],
      ),
    );
  }
}