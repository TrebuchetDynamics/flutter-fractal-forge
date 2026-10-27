import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

/// Shared geometry and paint for circular tools; callers own input and semantics.
class CircularToolSurface extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool pressed;
  final bool focused;
  final bool hovered;

  const CircularToolSurface({
    super.key,
    required this.icon,
    this.selected = false,
    this.pressed = false,
    this.focused = false,
    this.hovered = false,
  });

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityService?>();
    final touchSize = AccessibleSizing.touchTargetSize(
        largeTargets: accessibility?.largeTargetsEnabled ?? false);
    final reduceMotion = MediaQuery.of(context).disableAnimations ||
        (accessibility?.reducedMotionEnabled ?? false);
    return SizedBox.square(
      dimension: touchSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: reduceMotion ? Duration.zero : AppAnimations.fast,
            width: touchSize - 4,
            height: touchSize - 4,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              color: selected
                  ? null
                  : AppColors.surface.withValues(
                      alpha: pressed ? 0.86 : (hovered ? 0.84 : 0.74)),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: hovered ? 0.34 : 0.22)
                    : (pressed
                        ? AppColors.primaryLight.withValues(alpha: 0.62)
                        : Colors.white
                            .withValues(alpha: hovered ? 0.34 : 0.14)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: pressed ? 0.28 : 0.18),
                  blurRadius: pressed ? 14 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon,
                size: 20,
                color: selected
                    ? Colors.white
                    : (pressed
                        ? AppColors.primaryLight
                        : AppColors.textPrimary)),
          ),
          // Paint focus above the surface without padding that shrinks it.
          if (focused)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HighContrastColors.focusIndicator,
                      width: AccessibleSizing.focusIndicatorWidth,
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
