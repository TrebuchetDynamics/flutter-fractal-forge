import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animated_widgets.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_control_status.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

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
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

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

    return FadeIn(
      delay: widget.delay,
      child: Semantics(
        label: tooltip,
        button: true,
        onTap: activate,
        onLongPress: widget.onLongPress,
        child: Tooltip(
          message: tooltip,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: activate,
                onLongPress: widget.onLongPress,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final scale = active ? (1.0 + _pulse.value * 0.12) : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.primaryGradient : null,
                          color: active ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: active
                              ? null
                              : Border.all(
                                  color:
                                      AppColors.border.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: active
                                  ? AppColors.primary.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.18),
                              blurRadius: active ? 16 : 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          active ? Icons.pause_rounded : Icons.explore_rounded,
                          color:
                              active ? Colors.white : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (status.showsYieldBadge)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n?.autoExploreTitle ?? 'Auto-Explore',
                  style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n?.autoExploreSubtitle ??
                    'Automatically discover interesting areas',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              if (status.showsYieldBadge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.35)),
                  ),
                  child: const Text(
                    'Auto-pilot paused (user correction)',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.35)),
                ),
                child: const Text(
                  'Auto mode: Zoom-only (no auto-pan). You can pan freely.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n?.speedLabel ?? 'Speed',
                      style: AppTypography.labelLarge),
                  Text('${svc.speed.toStringAsFixed(1)}x',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.primary)),
                ],
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _runPrimaryAction(status.primaryAction, svc),
                      icon: Icon(status.showsPauseAction
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(
                        status.primaryActionLabel(
                          startLabel: l10n?.actionPlay ?? 'Play',
                          pauseLabel: l10n?.actionPause ?? 'Pause',
                          resumeLabel: 'Resume',
                        ),
                      ),
                    ),
                  ),
                  if (svc.isExploring) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: svc.stop,
                        icon: const Icon(Icons.stop_rounded),
                        label: Text(l10n?.actionStop ?? 'Stop'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
