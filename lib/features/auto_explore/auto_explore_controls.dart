import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_control_status.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

/// Keyboard-only alternate activation for [AutoExploreButton]'s long-press
/// secondary action (mirrors Shift+Click conventions).
class _LongPressActivateIntent extends Intent {
  const _LongPressActivateIntent();
}

/// Compact play/pause button shown in the viewer FAB stack.
class AutoExploreButton extends StatefulWidget {
  final VoidCallback? onLongPress;
  final Duration delay;

  const AutoExploreButton(
      {super.key, this.onLongPress, this.delay = Duration.zero});

  @override
  State<AutoExploreButton> createState() => _AutoExploreButtonState();
}

class _AutoExploreButtonState extends State<AutoExploreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AutoExploreService?>();
    if (svc == null) return const SizedBox.shrink();

    final status = AutoExploreControlStatus.fromPlayback(
      isExploring: svc.isExploring,
      isPaused: svc.isPaused,
      pausedByUserCorrection: svc.pausedByUserCorrection,
    );
    final active = status.isMotionActive;
    if (active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
    if (!active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }

    final l10n = AppLocalizations.of(context);
    final tooltip = status.tooltip(
      startLabel: l10n?.tooltipStartExplore ?? 'Start auto-explore',
      pauseLabel: l10n?.tooltipPauseExplore ?? 'Pause auto-explore',
      yieldedLabel: 'Auto-pilot paused',
    );

    void activate() {
      HapticFeedback.mediumImpact();
      _runPrimaryAction(status.primaryAction, svc);
    }

    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: FadeIn(
        delay: widget.delay,
        child: Semantics(
          excludeSemantics: true,
          sortKey: OrdinalSortKey(0),
          label: tooltip,
          hint: widget.onLongPress == null
              ? null
              : (l10n?.viewerSecondaryActionHint ??
                  'Long press or Shift+Enter opens the secondary action.'),
          button: true,
          onTap: activate,
          onLongPress: widget.onLongPress,
          child: Tooltip(
            message: tooltip,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FocusableActionDetector(
                  onShowFocusHighlight: (focused) {
                    if (_isFocused == focused) return;
                    setState(() => _isFocused = focused);
                  },
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
                    SingleActivator(LogicalKeyboardKey.enter, shift: true):
                        _LongPressActivateIntent(),
                  },
                  actions: {
                    ActivateIntent: CallbackAction<ActivateIntent>(
                      onInvoke: (_) {
                        activate();
                        return null;
                      },
                    ),
                    _LongPressActivateIntent:
                        CallbackAction<_LongPressActivateIntent>(
                      onInvoke: (_) {
                        widget.onLongPress?.call();
                        return null;
                      },
                    ),
                  },
                  child: GestureDetector(
                    onTap: activate,
                    onLongPress: widget.onLongPress,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final scale =
                            active ? (1.0 + _pulse.value * 0.04) : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox.square(
                            dimension: AccessibleSizing.minTouchTarget,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isFocused
                                        ? HighContrastColors.focusIndicator
                                        : Colors.transparent,
                                    width: AccessibleSizing.focusIndicatorWidth,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: AnimatedContainer(
                                  duration: AppAnimations.fast,
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: active
                                        ? AppColors.primaryGradient
                                        : null,
                                    color: active
                                        ? null
                                        : AppColors.surface
                                            .withValues(alpha: 0.74),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: active
                                          ? Colors.white.withValues(alpha: 0.22)
                                          : Colors.white
                                              .withValues(alpha: 0.14),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.18),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    active
                                        ? Icons.pause_rounded
                                        : Icons.explore_rounded,
                                    color: active
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (status.showsYieldBadge)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'Auto-pilot paused',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _runPrimaryAction(
  AutoExplorePrimaryAction action,
  AutoExploreService service,
) {
  switch (action) {
    case AutoExplorePrimaryAction.resumeFromTemporaryYield:
      service.resume();
      return;
    case AutoExplorePrimaryAction.pause:
    case AutoExplorePrimaryAction.startOrResume:
      service.toggle();
      return;
  }
}

/// Optional settings sheet opened via long-press.
class AutoExploreSettingsSheet extends StatelessWidget {
  const AutoExploreSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AutoExploreService>();
    final status = AutoExploreControlStatus.fromPlayback(
      isExploring: svc.isExploring,
      isPaused: svc.isPaused,
      pausedByUserCorrection: svc.pausedByUserCorrection,
    );
    final l10n = AppLocalizations.of(context);

    final primaryAction = ElevatedButton.icon(
      onPressed: () => _runPrimaryAction(status.primaryAction, svc),
      icon: Icon(status.showsPauseAction
          ? Icons.pause_rounded
          : Icons.play_arrow_rounded),
      label: Text(
        status.primaryActionLabel(
          startLabel: l10n?.actionPlay ?? 'Play',
          pauseLabel: l10n?.actionPause ?? 'Pause',
          resumeLabel: l10n?.actionResume ?? 'Resume',
        ),
      ),
    );
    final stopAction = OutlinedButton.icon(
      onPressed: svc.stop,
      icon: const Icon(Icons.stop_rounded),
      label: Text(l10n?.actionStop ?? 'Stop'),
    );

    return AppBottomSheet(
      maxHeightFactor: 0.82,
      children: [
        AppBottomSheetHeader(
          icon: Icons.explore_rounded,
          title: l10n?.autoExploreTitle ?? 'Auto-Explore',
          subtitle: l10n?.autoExploreSubtitle ??
              'Automatically discover interesting areas',
          onClose: () => Navigator.of(context).pop(),
        ),
        const Divider(height: 1, color: AppColors.divider),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (status.showsYieldBadge) ...[
                  _AutoExploreInfoCard(
                    icon: Icons.pause_circle_outline_rounded,
                    text: l10n?.autoExplorePausedUserCorrection ??
                        'Auto-pilot paused while you adjust the view.',
                    emphasized: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _AutoExploreInfoCard(
                  icon: Icons.zoom_in_map_rounded,
                  text: l10n?.autoExploreZoomOnlyDescription ??
                      'Zoom-only mode. Auto Explore leaves panning in your control.',
                ),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final label = Text(
                      l10n?.speedLabel ?? 'Speed',
                      style: AppTypography.labelLarge,
                    );
                    final value = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${svc.speed.toStringAsFixed(1)}x',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.primaryLight),
                      ),
                    );
                    if (MediaQuery.textScalerOf(context).scale(14) >= 21) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          label,
                          const SizedBox(height: AppSpacing.xs),
                          Align(alignment: Alignment.centerRight, child: value),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [label, value],
                    );
                  },
                ),
                Slider(
                  value: svc.speed,
                  min: AutoExploreSpeed.min,
                  max: AutoExploreSpeed.max,
                  divisions: AutoExploreSpeed.sliderDivisions,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    svc.speed = v;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackActions = constraints.maxWidth < 340 ||
                        MediaQuery.textScalerOf(context).scale(14) >= 21;
                    if (!svc.isExploring) return primaryAction;
                    if (stackActions) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          primaryAction,
                          const SizedBox(height: AppSpacing.sm),
                          stopAction,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: primaryAction),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: stopAction),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AutoExploreInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;

  const _AutoExploreInfoCard({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        emphasized ? AppColors.primaryLight : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: emphasized
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceVariant.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emphasized
              ? AppColors.primaryLight.withValues(alpha: 0.4)
              : AppColors.glassBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
