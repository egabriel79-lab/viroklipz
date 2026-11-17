import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const List<String> _filters = [
    'Todo',
    'Comprar',
    'Recompensas',
    'Pago',
    'Ajuste de la plataforma',
    'Reembolsar',
    'Deducción',
  ];

  String _selectedFilter = 'Todo';

  void _openFilterPickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrar por tipo de transacción',
                      style: TextStyle(
                        color: Color(0xFF09090B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF71717A)),
                    ),
                  ],
                ),
                const Divider(height: 1),
                ..._filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      filter,
                      style: TextStyle(
                        color: const Color(0xFF09090B),
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFFE2C55),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF09090B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Historial de transacciones',
          style: TextStyle(
            color: Color(0xFF09090B),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF18181B),
            ),
            onPressed: _openFilterPickerSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF4F4F5)),
        ),
      ),
      body: Column(
        children: [
          // Fila de filtros horizontal con SingleChildScrollView
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF4F4F5)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: _filters.map((filter) {
                  final bool isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3F3F46),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Estado vacío centrado
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        size: 46,
                        color: Color(0xFFD4D4D8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aún no hay transacciones',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_selectedFilter != 'Todo') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Filtro activo: $_selectedFilter',
                        style: const TextStyle(
                          color: Color(0xFF71717A),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _openFilterPickerSheet,
                      child: const Text(
                        'Selecciona otro filtro',
                        style: TextStyle(
                          color: Color(0xFFFE2C55),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer informativo
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: Text(
                'Saldo no es un producto financiero. Los detalles que se muestran son solo para fines informativos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}