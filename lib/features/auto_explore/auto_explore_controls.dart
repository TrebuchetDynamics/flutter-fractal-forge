import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_tool_button.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_control_status.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

/// Compact play/pause button shown in the viewer FAB stack.
class AutoExploreButton extends StatelessWidget {
  final VoidCallback? onLongPress;
  final Duration delay;
  final double sortOrder;

  const AutoExploreButton({
    super.key,
    this.onLongPress,
    this.delay = Duration.zero,
    this.sortOrder = 0,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AutoExploreService?>();
    if (service == null) return const SizedBox.shrink();
    final status = AutoExploreControlStatus.fromPlayback(
      isExploring: service.isExploring,
      isPaused: service.isPaused,
      pausedByUserCorrection: service.pausedByUserCorrection,
    );
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppToolButton(
          icon: status.isMotionActive
              ? Icons.pause_rounded
              : Icons.explore_rounded,
          tooltip: status.tooltip(
            startLabel: l10n?.tooltipStartExplore ?? 'Start auto-explore',
            pauseLabel: l10n?.tooltipPauseExplore ?? 'Pause auto-explore',
            yieldedLabel:
                l10n?.autoExplorePausedUserCorrection ?? 'Auto-pilot paused',
          ),
          selected: status.isMotionActive,
          onPressed: () => _runPrimaryAction(status.primaryAction, service),
          onLongPress: onLongPress,
          delay: delay,
          sortOrder: sortOrder,
        ),
        if (status.showsYieldBadge)
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Icon(Icons.pause_circle_filled_rounded,
                    size: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
      ],
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

    return AppOptionsSheet(
      maxHeightFactor: 0.82,
      icon: Icons.explore_rounded,
      title: l10n?.autoExploreTitle ?? 'Auto-Explore',
      subtitle: l10n?.autoExploreSubtitle ??
          'Automatically discover interesting areas',
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
