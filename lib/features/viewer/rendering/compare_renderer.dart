import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';

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
  final FractalRenderSnapshotSink? activeSnapshotSink;

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
    this.activeSnapshotSink,
  });

  @override
  Widget build(BuildContext context) {
    // A rebuild can transfer active ownership to the other pane. Clear first so
    // capture cannot replay the previous pane before the new owner publishes.
    activeSnapshotSink?.snapshot = null;
    final controllerA = context.watch<FractalController>();

    Widget paneA = _ComparePane(
      isActive: activePane == 0,
      label: 'A',
      onTap: () => onOpenPane(0),
      child: ChangeNotifierProvider.value(
        value: controllerA,
        child: FractalRenderer(
          boundaryKey: keyA,
          renderSnapshotSink: activePane == 0 ? activeSnapshotSink : null,
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
          renderSnapshotSink: activePane == 1 ? activeSnapshotSink : null,
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
        final targetWidth = AccessibleSizing.minTouchTarget +
            Theme.of(context).visualDensity.baseSizeAdjustment.dx.clamp(0, 8);

        return Stack(
          children: [
            Positioned.fill(child: paneA),
            Positioned.fill(
              child: ClipRect(
                clipper: _CompareWipeClipper(clamped),
                child: paneB,
              ),
            ),
            Positioned(
              // Only the affordance owns input, not a canvas-height strip.
              left: (x - targetWidth / 2).clamp(0, width - targetWidth),
              top: (constraints.maxHeight - 64) / 2,
              height: 64,
              width: targetWidth,
              child: _CompareDividerHandle(
                value: clamped,
                onStep: (delta) =>
                    onDividerChanged((clamped + delta).clamp(0.05, 0.95)),
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

// A full-size pane is clipped for painting AND hit testing. Align.widthFactor
// under Positioned.fill's tight constraints did neither, hiding pane A's input.
class _CompareWipeClipper extends CustomClipper<Rect> {
  final double divider;
  const _CompareWipeClipper(this.divider);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * divider, 0, size.width, size.height);

  @override
  bool shouldReclip(_CompareWipeClipper oldClipper) =>
      divider != oldClipper.divider;
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

class _CompareDividerHandle extends StatefulWidget {
  final double value;
  final ValueChanged<double> onStep;
  final ValueChanged<double> onDrag;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  const _CompareDividerHandle({
    required this.value,
    required this.onStep,
    required this.onDrag,
    required this.onTapLeft,
    required this.onTapRight,
  });

  @override
  State<_CompareDividerHandle> createState() => _CompareDividerHandleState();
}

class _CompareDividerHandleState extends State<_CompareDividerHandle> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final percent = (widget.value * 100).round();
    return Semantics(
      label: AppLocalizations.of(context)!.compareDivider,
      slider: true,
      value: '$percent%',
      increasedValue:
          '${((widget.value + .05).clamp(.05, .95) * 100).round()}%',
      decreasedValue:
          '${((widget.value - .05).clamp(.05, .95) * 100).round()}%',
      onIncrease: () => widget.onStep(.05),
      onDecrease: () => widget.onStep(-.05),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              widget.onStep(-.05),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              widget.onStep(.05),
        },
        child: Focus(
          onFocusChange: (value) => setState(() => _focused = value),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
            onTapUp: (details) {
              if (details.localPosition.dx < context.size!.width / 2) {
                widget.onTapLeft();
              } else {
                widget.onTapRight();
              }
            },
            child: Center(
              child: Container(
                width: 28,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _focused
                        ? AppColors.primaryLight
                        : Colors.white.withValues(alpha: 0.18),
                    width: _focused ? AccessibleSizing.focusIndicatorWidth : 1,
                  ),
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
          ),
        ),
      ),
    );
  }
}
