import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/models/fractal_palette.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/glassmorphic_widgets.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

/// A horizontal scrolling palette selector with visual previews.
///
/// Displays all built-in and user palettes as gradient strips
/// that can be tapped to select. Each palette shows its name
/// and a visual preview of the gradient.
class PaletteSelector extends StatelessWidget {
  final String? selectedPaletteId;
  final ValueChanged<String>? onPaletteSelected;
  final double height;

  const PaletteSelector({
    super.key,
    this.selectedPaletteId,
    this.onPaletteSelected,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final paletteService = context.watch<PaletteService>();
    final allPalettes = paletteService.allPalettes;

    if (allPalettes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Color Palette',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allPalettes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              final palette = allPalettes[index];
              final isSelected = palette.id == selectedPaletteId;

              return _PaletteCard(
                palette: palette,
                isSelected: isSelected,
                onTap: () => onPaletteSelected?.call(palette.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A single palette card with gradient preview.
class _PaletteCard extends StatefulWidget {
  final FractalPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<_PaletteCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final stops = widget.palette.stops;

    // Build gradient from palette stops
    final gradientColors = stops.map((s) {
      return Color(s.colorArgb);
    }).toList();

    final gradientStops = stops.map((s) => s.position).toList();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppAnimations.paletteSelector,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.1),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(11),
                    ),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      stops: gradientStops,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Text(
                  widget.palette.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact palette button that shows the current palette as a mini-preview.
///
/// Tapping opens a bottom sheet with full palette selector.
class PaletteSelectorButton extends StatelessWidget {
  final VoidCallback? onTap;

  const PaletteSelectorButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicButton(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Palette',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension to integrate palette selection into FractalController.
extension PaletteSelection on FractalController {
  /// Gets the current palette ID from params, or default.
  String? get currentPaletteId {
    // Palette is stored as a custom palette ID or derived from colorScheme
    final customPalette = params['paletteId'] as String?;
    if (customPalette != null && customPalette.isNotEmpty) {
      return customPalette;
    }

    // Map colorScheme index to built-in palette
    final colorScheme = (params['colorScheme'] as num?)?.toInt() ?? 0;
    return _mapColorSchemeToPaletteId(colorScheme);
  }

  /// Sets the active palette by ID.
  void setPalette(String paletteId) {
    updateParam('paletteId', paletteId);

    // Also update colorScheme to match for backward compatibility
    final colorScheme = _mapPaletteIdToColorScheme(paletteId);
    if (colorScheme != null) {
      updateParam('colorScheme', colorScheme);
    }
  }

  static String? _mapColorSchemeToPaletteId(int colorScheme) {
    // Map default color schemes to palette IDs
    switch (colorScheme) {
      case 0:
        return 'builtin_fire';
      case 1:
        return 'builtin_ocean';
      case 2:
        return 'builtin_psychedelic';
      case 3:
        return 'builtin_grayscale';
      default:
        return 'builtin_fire';
    }
  }

  static int? _mapPaletteIdToColorScheme(String paletteId) {
    switch (paletteId) {
      case 'builtin_fire':
        return 0;
      case 'builtin_ocean':
        return 1;
      case 'builtin_psychedelic':
        return 2;
      case 'builtin_grayscale':
        return 3;
      default:
        return null;
    }
  }
}
