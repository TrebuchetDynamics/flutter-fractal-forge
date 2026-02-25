import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

class FractalNavigationDock extends StatelessWidget {
  final String zoomLabel;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final VoidCallback? onZoomIn;
  final VoidCallback? onRandom;

  const FractalNavigationDock({
    super.key,
    required this.zoomLabel,
    required this.onZoomOut,
    required this.onResetView,
    required this.onZoomIn,
    required this.onRandom,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Quick navigation. Current zoom $zoomLabel. Actions: zoom out, reset view, zoom in, random fractal.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DockButton(
              icon: Icons.remove_rounded,
              label: 'Out',
              tooltip: 'Zoom out',
              onTap: onZoomOut,
            ),
            _DockButton(
              icon: Icons.home_filled,
              label: 'Reset',
              tooltip: 'Reset view',
              onTap: onResetView,
            ),
            _DockButton(
              icon: Icons.add_rounded,
              label: 'In',
              tooltip: 'Zoom in',
              onTap: onZoomIn,
            ),
            _DockButton(
              icon: Icons.shuffle_rounded,
              label: 'Random',
              tooltip: 'Random fractal',
              onTap: onRandom,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;

  const _DockButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              width: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: onTap == null
                          ? AppColors.textMuted.withValues(alpha: 0.6)
                          : Colors.white,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: onTap == null
                            ? AppColors.textMuted.withValues(alpha: 0.7)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
