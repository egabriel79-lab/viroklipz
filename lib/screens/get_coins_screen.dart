import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/coin_package.dart';
import '../theme/app_colors.dart';

class GetCoinsScreen extends StatefulWidget {
  const GetCoinsScreen({super.key});

  @override
  State<GetCoinsScreen> createState() => _GetCoinsScreenState();
}

class _GetCoinsScreenState extends State<GetCoinsScreen> {
  static const double _baseRateUsd = 0.0079;

  int? _selectedIndex = 0;
  final TextEditingController _customCoinsController = TextEditingController();
  int _customCoins = 0;

  @override
  void dispose() {
    _customCoinsController.dispose();
    super.dispose();
  }

  CoinPackage? get _selectedPackage =>
      _selectedIndex != null ? kCoinPackages[_selectedIndex!] : null;

  bool get _hasDiscount => _customCoins > 1000;

  double get _customTotalUsd {
    final double rawTotal = _customCoins * _baseRateUsd;
    return _hasDiscount ? rawTotal * 0.90 : rawTotal;
  }

  void _selectPackage(int index) {
    _customCoinsController.clear();
    setState(() {
      _selectedIndex = index;
      _customCoins = 0;
    });
  }

  void _onCustomCoinsChanged(String value) {
    final int parsed = int.tryParse(value.trim()) ?? 0;
    setState(() {
      _selectedIndex = null;
      _customCoins = parsed;
    });
  }

  void _triggerSimulatedCheckout() {
    if (_selectedPackage == null && _customCoins <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirigiendo a pasarela de pago... (Simulación)'),
        backgroundColor: Color(0xFF27272A),
      ),
    );
  }

  Widget _buildCoinIcon({double size = 22}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFDE047), Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'V',
        style: TextStyle(
          color: const Color(0xFF451A03),
          fontWeight: FontWeight.w900,
          fontSize: size * 0.54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CoinPackage? pkg = _selectedPackage;
    final String formattedCustomTotal = _customTotalUsd.toStringAsFixed(2);
    final bool isButtonEnabled = pkg != null || _customCoins > 0;

    final String buttonText;
    if (pkg != null) {
      buttonText = 'Consigue ${pkg.totalCoins} Monedas (${pkg.priceText})';
    } else if (_customCoins > 0) {
      buttonText = 'Consigue $_customCoins Monedas (USD $formattedCustomTotal)';
    } else {
      buttonText = 'Ingresa una cantidad o elige un paquete';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Obtener Monedas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historial de transacciones: Sin recargas'),
                  backgroundColor: Color(0xFF27272A),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Sección Saldo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo de Monedas',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildCoinIcon(size: 32),
                          const SizedBox(width: 10),
                          const Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Banner de Regalo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFCE7F3), Color(0xFFFFE4EC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Rosas de bonus y Monedas en la primera recarga...',
                              style: TextStyle(
                                color: Color(0xFF881337),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Precios más económicos que nunca en Viroklipz',
                              style: TextStyle(
                                color: Color(0xFFBE123C),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('🌹', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Sección Recarga (Grid 3 columnas)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'RECARGAR',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Incluye bono extra',
                      style: TextStyle(
                        color: AppColors.magenta,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kCoinPackages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final item = kCoinPackages[index];
                    final bool isSelected = index == _selectedIndex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _selectPackage(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.magenta.withValues(alpha: 0.14)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFE2C55)
                                : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCoinIcon(size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.coins}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${item.bonus} Bono',
                              style: const TextStyle(
                                color: Color(0xFFFE2C55),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.priceText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 4. Calculadora de monedas personalizada
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17171A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculadora personalizada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ingresa la cantidad de monedas que deseas comprar:',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customCoinsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: _onCustomCoinsChanged,
                              decoration: InputDecoration(
                                hintText: 'Ej. 250',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                filled: true,
                                fillColor: const Color(0xFF1E1E1E),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.magenta,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total a pagar: USD $formattedCustomTotal',
                                style: const TextStyle(
                                  color: AppColors.magenta,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _hasDiscount
                                    ? '10% de descuento aplicado'
                                    : '+1000 monedas = 10% dto.',
                                style: TextStyle(
                                  color: _hasDiscount
                                      ? Colors.greenAccent[400]
                                      : Colors.grey[500],
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Texto Legal
                const Text(
                  'Al recargar, confirmas que eres mayor de 18 años y aceptas los Términos de Artículos Virtuales de Viroklipz. Las monedas no son reembolsables ni canjeables por dinero en efectivo.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 6. Botón Inferior con degradado naranja/rosa
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Opacity(
              opacity: isButtonEnabled ? 1.0 : 0.5,
              child: GestureDetector(
                onTap: isButtonEnabled ? _triggerSimulatedCheckout : null,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.orange, AppColors.magenta],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}