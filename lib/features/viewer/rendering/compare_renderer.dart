import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

class CompareRenderer extends StatelessWidget {
  final GlobalKey keyA;
  final GlobalKey keyB;
  final FractalController controllerB;
  final bool sliderMode;
  final double divider;
  final int activePane;
  final ValueChanged<double> onDividerChanged;
  final ValueChanged<int> onActivePaneChanged;
  final VoidCallback onOpenControls;
  final VoidCallback onOpenPresets;
  final VoidCallback onOpenExport;
  final VoidCallback? onUserInteraction;
  final VoidCallback? onUserInteractionStart;
  final VoidCallback? onUserInteractionEnd;
  final bool freezeFrame;

  const CompareRenderer({
    super.key,
    required this.keyA,
    required this.keyB,
    required this.controllerB,
    required this.sliderMode,
    required this.divider,
    required this.activePane,
    required this.onDividerChanged,
    required this.onActivePaneChanged,
    required this.onOpenControls,
    required this.onOpenPresets,
    required this.onOpenExport,
    this.onUserInteraction,
    this.onUserInteractionStart,
    this.onUserInteractionEnd,
    required this.freezeFrame,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.read<FractalController>();

    Widget paneA = _ComparePane(
      isActive: activePane == 0,
      label: 'A',
      onTap: () => onOpenPane(0),
      child: ChangeNotifierProvider.value(
        value: a,
        child: FractalRenderer(
          boundaryKey: keyA,
          animationEnabled: !freezeFrame,
          gesturesEnabled: activePane == 0,
          onOpenControls: onOpenControls,
          onOpenPresets: onOpenPresets,
          onOpenExport: onOpenExport,
          onUserInteraction: onUserInteraction,
          onUserInteractionStart: onUserInteractionStart,
          onUserInteractionEnd: onUserInteractionEnd,
        ),
      ),
    );

    Widget paneB = _ComparePane(
      isActive: activePane == 1,
      label: 'B',
      onTap: () => onOpenPane(1),
      child: ChangeNotifierProvider.value(
        value: controllerB,
        child: FractalRenderer(
          boundaryKey: keyB,
          animationEnabled: !freezeFrame,
          gesturesEnabled: activePane == 1,
          onOpenControls: onOpenControls,
          onOpenPresets: onOpenPresets,
          onOpenExport: onOpenExport,
          onUserInteraction: onUserInteraction,
          onUserInteractionStart: onUserInteractionStart,
          onUserInteractionEnd: onUserInteractionEnd,
        ),
      ),
    );

    if (!sliderMode) {
      return Row(
        children: [
          Expanded(child: paneA),
          Container(
              width: 1, color: AppColors.surfaceVariant.withValues(alpha: 0.6)),
          Expanded(child: paneB),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final clamped = divider.clamp(0.05, 0.95);
        final x = width * clamped;

        return Stack(
          children: [
            Positioned.fill(child: paneA),
            Positioned.fill(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1.0 - clamped,
                  child: paneB,
                ),
              ),
            ),
            Positioned(
              left: x - 18,
              top: 0,
              bottom: 0,
              width: 36,
              child: _CompareDividerHandle(
                onDrag: (dx) {
                  final next = (x + dx) / width;
                  onDividerChanged(next.clamp(0.05, 0.95));
                },
                onTapLeft: () => onOpenPane(0),
                onTapRight: () => onOpenPane(1),
              ),
            ),
          ],
        );
      },
    );
  }

  void onOpenPane(int pane) {
    onActivePaneChanged(pane);
  }
}

class _ComparePane extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _ComparePane({
    required this.child,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            left: 12,
            top: MediaQuery.of(context).padding.top + 12,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.primary : AppColors.surfaceVariant)
                    .withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isActive ? 0.35 : 0.15),
                ),
              ),
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (isActive)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 2,
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

class _CompareDividerHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  const _CompareDividerHandle({
    required this.onDrag,
    required this.onTapLeft,
    required this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
      onTapUp: (details) {
        final localX = details.localPosition.dx;
        if (localX < 18) {
          onTapLeft();
        } else {
          onTapRight();
        }
      },
      child: Center(
        child: Container(
          width: 28,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.drag_handle_rounded,
              color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
