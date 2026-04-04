import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// An enhanced gradient overlay for catalog thumbnails.
///
/// Features:
/// - Multi-layer gradient with depth
/// - Shimmer accent line animation
/// - Subtle vignette effect
/// - Category-matched color accent
class EnhancedThumbnailOverlay extends StatelessWidget {
  final Color accentColor;
  final bool is3D;
  final bool isFeatured;

  const EnhancedThumbnailOverlay({
    super.key,
    required this.accentColor,
    this.is3D = false,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top gradient overlay for depth
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom gradient overlay for text legibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Accent gradient line at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.9),
                  accentColor.withValues(alpha: 0.6),
                  accentColor.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),

        // Vignette effect for depth
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.15),
              ],
            ),
          ),
        ),

        // Featured highlight glow
        if (isFeatured)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A styled dimension badge with glassmorphism effect.
class DimensionBadge extends StatelessWidget {
  final bool is3D;

  const DimensionBadge({
    super.key,
    required this.is3D,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = is3D
        ? AppColors.warning.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.15);
    final borderColor =
        is3D ? AppColors.warning : Colors.white.withValues(alpha: 0.4);
    final textColor = is3D ? Colors.black87 : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        is3D ? '3D' : '2D',
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// A shimmer loading effect with gradient accent.
class EnhancedShimmer extends StatefulWidget {
  final double height;

  const EnhancedShimmer({
    super.key,
    this.height = double.infinity,
  });

  @override
  State<EnhancedShimmer> createState() => _EnhancedShimmerState();
}

class _EnhancedShimmerState extends State<EnhancedShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.shimmer,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final gradient = LinearGradient(
          begin: Alignment(-1.0 + _controller.value * 2.0, 0),
          end: Alignment(0.0 + _controller.value * 2.0, 0),
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.5),
            AppColors.surfaceVariant.withValues(alpha: 0.8),
            AppColors.surfaceVariant.withValues(alpha: 0.5),
          ],
        );

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
          ),
        );
      },
    );
  }
}

/// Extension method to wrap any thumbnail with enhanced overlay.
extension EnhancedThumbnail on Widget {
  Widget withEnhancedOverlay({
    required Color accentColor,
    bool is3D = false,
    bool isFeatured = false,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        this,
        EnhancedThumbnailOverlay(
          accentColor: accentColor,
          is3D: is3D,
          isFeatured: isFeatured,
        ),
      ],
    );
  }
}
