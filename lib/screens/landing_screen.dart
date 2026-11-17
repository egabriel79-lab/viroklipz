import 'dart:ui';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'register_form_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterFormScreen()),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Resplandores ambientales neón de fondo
          Positioned(
            top: -90,
            left: -60,
            child: _AmbientGlow(
              size: 280,
              color: const Color(0xFFFF6B00).withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: 220,
            right: -80,
            child: _AmbientGlow(
              size: 260,
              color: const Color(0xFF9333EA).withValues(alpha: 0.22),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isCompact = constraints.maxWidth < 520;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. BARRA DE NAVEGACIÓN SUPERIOR (Solo Logo + Únete gratis)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Viroklipz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            _NeonGradientButton(
                              label: 'Únete gratis',
                              compact: isCompact,
                              onPressed: _navigateToRegister,
                            ),
                          ],
                        ),
                      ),

                      // 2. SECCIÓN HERO
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          children: [
                            Text(
                              'Viroklipz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCompact ? 44 : 54,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: -1.2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: isCompact ? 32 : 42,
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                  letterSpacing: -0.8,
                                  color: Colors.white,
                                ),
                                children: [
                                  const TextSpan(text: 'Comparte tus '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFFF8A00),
                                          Color(0xFFFF3D5A),
                                          Color(0xFFEC4899),
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        'Videos',
                                        style: TextStyle(
                                          fontSize: isCompact ? 32 : 42,
                                          fontWeight: FontWeight.w900,
                                          height: 1.08,
                                          letterSpacing: -0.8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 520),
                              child: Text(
                                'La red social de videos verticales. Sube tus clips, descubre creadores increíbles y hazte viral en segundos.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _NeonGradientButton(
                                  label: 'Crear cuenta',
                                  onPressed: _navigateToRegister,
                                ),
                                OutlinedButton.icon(
                                  onPressed: _navigateToLogin,
                                  icon: const Icon(
                                    Icons.login_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Inicio',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.04),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Visual central 3D futurista con Glassmorphism frame
                            _GlassCard(
                              padding: const EdgeInsets.all(6),
                              borderRadius: 22,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFF6B00),
                                            Color(0xFF9333EA),
                                            Color(0xFF1D4ED8),
                                          ],
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.view_in_ar_rounded,
                                            color: Colors.white,
                                            size: 54,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Viroklipz Social',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cómo funciona
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: _GlassCard(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cómo funciona',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '01. Graba o sube tus videos verticales directamente desde tu teléfono.
'
                                '02. Edita, ponle tu música favorita y dale tu estilo único.
'
                                '03. Publica en el feed, compártelo con tus amigos y consigue seguidores.',
                                style: TextStyle(
                                  color: Color(0xFFD4D4D8),
                                  fontSize: 13.5,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 4. SOCIAL PROOF (Testimonios)
                      const SizedBox(height: 22),
                      Column(
                        children: [
                          SizedBox(
                            height: 38,
                            width: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: List.generate(5, (index) {
                                final colors = [
                                  const Color(0xFFFF6B00),
                                  const Color(0xFFEC4899),
                                  const Color(0xFF9333EA),
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF10B981),
                                ];
                                return Positioned(
                                  left: index * 24.0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors[index],
                                      border: Border.all(
                                        color: const Color(0xFF0F0F0F),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (_) => const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFBBF24),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Amado por más de 100,000 creadores',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 110,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _NeonGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool compact;

  const _NeonGradientButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(compact ? 11 : 14),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 13 : 22,
              vertical: compact ? 9 : 14,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12.5 : 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}