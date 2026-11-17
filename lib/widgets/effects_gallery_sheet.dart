import 'package:flutter/material.dart';
import '../services/royalty_free_media_service.dart';
import '../theme/app_colors.dart';

class EffectsPickerResult {
  final VideoEffectOverlay? effect;
  const EffectsPickerResult(this.effect);
}

class EffectsGallerySheet extends StatelessWidget {
  final String? selectedEffectId;

  const EffectsGallerySheet({super.key, this.selectedEffectId});

  @override
  Widget build(BuildContext context) {
    const overlays = RoyaltyFreeMediaService.effectOverlays;

    return Container(
      height: MediaQuery.of(context).size.height * 0.56,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Efectos visuales (Overlays)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const EffectsPickerResult(null)),
                  child: const Text(
                    'Quitar efecto',
                    style: TextStyle(
                      color: AppColors.magenta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: overlays.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final bool isNone = selectedEffectId == null;
                  return GestureDetector(
                    onTap: () =>
                        Navigator.pop(context, const EffectsPickerResult(null)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isNone ? const Color(0xFF25F4EE) : Colors.white12,
                          width: isNone ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ninguno',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final VideoEffectOverlay effect = overlays[index - 1];
                final bool isSelected = selectedEffectId == effect.id;

                return GestureDetector(
                  onTap: () => Navigator.pop(context, EffectsPickerResult(effect)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF25F4EE)
                                  : Colors.white12,
                              width: isSelected ? 2.2 : 1,
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: _gradientForEffect(effect.id),
                                ),
                                child: Center(
                                  child: Icon(
                                    _iconForEffect(effect.id),
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 32,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    effect.tag,
                                    style: const TextStyle(
                                      color: Color(0xFF25F4EE),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        effect.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF25F4EE)
                              : Colors.white,
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
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

  static LinearGradient _gradientForEffect(String effectId) {
    switch (effectId) {
      case 'light_leaks':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFE91E63)],
        );
      case 'neon_particles':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF25F4EE), Color(0xFF673AB7)],
        );
      case 'bokeh_nights':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFF38BDF8)],
        );
      case 'vhs_retro':
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        );
    }
  }

  static IconData _iconForEffect(String effectId) {
    switch (effectId) {
      case 'light_leaks':
        return Icons.flare_rounded;
      case 'neon_particles':
        return Icons.auto_awesome_rounded;
      case 'bokeh_nights':
        return Icons.blur_on_rounded;
      case 'vhs_retro':
      default:
        return Icons.movie_filter_rounded;
    }
  }
}