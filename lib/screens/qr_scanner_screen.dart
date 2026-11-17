import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'profile_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Extrae el nombre de usuario (ej. "@mateo") de una URL tipo
  /// https://viroklipz.app/profile/@mateo
  String _extractUsername(String rawValue) {
    final trimmed = rawValue.trim();
    final Uri? uri = Uri.tryParse(trimmed);

    if (uri != null && uri.pathSegments.isNotEmpty) {
      final profileIdx = uri.pathSegments.indexOf('profile');
      String candidate;
      if (profileIdx != -1 && profileIdx + 1 < uri.pathSegments.length) {
        candidate = uri.pathSegments[profileIdx + 1];
      } else {
        candidate = uri.pathSegments.last;
      }

      if (candidate.isNotEmpty) {
        return candidate.startsWith('@') ? candidate : '@$candidate';
      }
    }

    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    _isProcessing = true;
    await controller.stop();

    final String username = _extractUsername(rawValue);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          embeddedInMainShell: false,
          username: username,
        ),
      ),
    );
  }

  Future<void> _toggleTorch() async {
    try {
      await controller.toggleTorch();
      if (!mounted) return;
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Linterna no disponible en este dispositivo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double scanAreaSize = 250;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cámara en vivo con MobileScanner
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // 2. Overlay oscuro con recorte transparente central y bordes
          CustomPaint(
            painter: _ScannerOverlayPainter(
              scanAreaSize: scanAreaSize,
              borderRadius: 20,
              cornerColor: Colors.white,
            ),
          ),

          // 3. Controles superiores, texto guía y linterna inferior
          SafeArea(
            child: Column(
              children: [
                // Botón "X" en la esquina superior izquierda para cancelar
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Texto guía arriba del recuadro de escaneo
                const Text(
                  'Escanea el código QR de un amigo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Espacio reservado del recuadro transparente
                const SizedBox(
                  width: scanAreaSize,
                  height: scanAreaSize,
                ),

                const Spacer(),

                // Botón de linterna (flash) en la parte inferior
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _toggleTorch,
                        iconSize: 28,
                        padding: const EdgeInsets.all(14),
                        style: IconButton.styleFrom(
                          backgroundColor: _isTorchOn
                              ? Colors.amber.withValues(alpha: 0.2)
                              : const Color(0xFF27272A).withValues(alpha: 0.8),
                          side: BorderSide(
                            color: _isTorchOn
                                ? Colors.amber
                                : Colors.white.withValues(alpha: 0.25),
                            width: _isTorchOn ? 1.5 : 1,
                          ),
                        ),
                        icon: Icon(
                          _isTorchOn
                              ? Icons.flashlight_on_rounded
                              : Icons.flashlight_off_rounded,
                          color: _isTorchOn ? Colors.amber : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isTorchOn ? 'Linterna activada' : 'Linterna',
                        style: TextStyle(
                          color: _isTorchOn ? Colors.amber : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              _isTorchOn ? FontWeight.w600 : FontWeight.w500,
                        ),
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
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderRadius;
  final Color cornerColor;

  _ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.borderRadius,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Offset.zero & size;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );
    final RRect scanRRect = RRect.fromRectAndRadius(
      scanRect,
      Radius.circular(borderRadius),
    );

    // Oscurece el resto de la pantalla dejando el recuadro central transparente
    final Path overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(fullRect)
      ..addRRect(scanRRect);

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );

    // Borde sutil completo
    canvas.drawRRect(
      scanRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Esquinas blancas destacadas
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 28;
    final double left = scanRect.left;
    final double top = scanRect.top;
    final double right = scanRect.right;
    final double bottom = scanRect.bottom;

    // Arriba-izquierda
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLen)
        ..lineTo(left, top + borderRadius)
        ..quadraticBezierTo(left, top, left + borderRadius, top)
        ..lineTo(left + cornerLen, top),
      cornerPaint,
    );
    // Arriba-derecha
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLen, top)
        ..lineTo(right - borderRadius, top)
        ..quadraticBezierTo(right, top, right, top + borderRadius)
        ..lineTo(right, top + cornerLen),
      cornerPaint,
    );
    // Abajo-izquierda
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLen)
        ..lineTo(left, bottom - borderRadius)
        ..quadraticBezierTo(left, bottom, left + borderRadius, bottom)
        ..lineTo(left + cornerLen, bottom),
      cornerPaint,
    );
    // Abajo-derecha
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLen, bottom)
        ..lineTo(right - borderRadius, bottom)
        ..quadraticBezierTo(right, bottom, right, bottom - borderRadius)
        ..lineTo(right, bottom - cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAreaSize != scanAreaSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerColor != cornerColor;
  }
}