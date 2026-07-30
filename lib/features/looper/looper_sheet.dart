import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

class LooperSheet extends StatelessWidget {
  final LooperController controller;
  final bool isExporting;
  final VoidCallback onExportGif;

  const LooperSheet({
    super.key,
    required this.controller,
    required this.isExporting,
    required this.onExportGif,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final seconds = controller.duration.inSeconds;
        final secondsLabel = l10n.looperSeconds(seconds);
        return AppBottomSheet(
          maxHeightFactor: 0.68,
          children: [
            AppBottomSheetHeader(
              icon: Icons.loop_rounded,
              title: l10n.looperTitle,
              subtitle: l10n.looperSubtitle,
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('looperSetAButton'),
                            onPressed: controller.setAFromCurrent,
                            icon: Icon(controller.a == null
                                ? Icons.looks_one_outlined
                                : Icons.check_circle_rounded),
                            label: Text(l10n.looperSetA),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('looperSetBButton'),
                            onPressed: controller.a == null
                                ? null
                                : controller.setBFromCurrent,
                            icon: Icon(controller.b == null
                                ? Icons.looks_two_outlined
                                : Icons.check_circle_rounded),
                            label: Text(l10n.looperSetB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (var i = 2; i < controller.points.length; i++)
                          InputChip(
                            label: Text(l10n.looperUpdatePoint(
                                LooperController.labelForIndex(i))),
                            // Without this every delete affordance announces
                            // itself as the bare word "Delete", so a screen
                            // reader hears the same name once per keyframe with
                            // nothing to tell them apart.
                            deleteButtonTooltipMessage: l10n.looperRemovePoint(
                                LooperController.labelForIndex(i)),
                            onPressed: () => controller.setPointFromCurrent(i),
                            onDeleted: () => controller.removePoint(i),
                          ),
                        if (controller.points.length >= 2)
                          ActionChip(
                            key: const ValueKey('looperAddPointButton'),
                            avatar: const Icon(Icons.add_rounded),
                            label: Text(l10n.looperAddPoint(
                                LooperController.labelForIndex(
                                    controller.points.length))),
                            onPressed: controller.addPointFromCurrent,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Both sides bounded. Unbounded, this row overflowed to the
                    // right from a 1.3x text scale upward — 31px at 1.3x on a
                    // 360-wide screen and 547px at 3.0x on a 320-wide one.
                    // Excluded from semantics because the Semantics below
                    // carries the same name and value for the slider.
                    ExcludeSemantics(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.looperDuration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              l10n.looperDurationValue(seconds),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Named, or the slider announces only "6s" and never says
                    // what the 6 seconds are.
                    MergeSemantics(
                      child: Semantics(
                        label: l10n.looperDuration,
                        value: secondsLabel,
                        hint: l10n.semanticSliderAdjust('1', '15'),
                        slider: true,
                        child: Slider(
                          key: const ValueKey('looperDurationSlider'),
                          min: 1,
                          max: 15,
                          divisions: 14,
                          value: seconds.toDouble().clamp(1, 15),
                          label: secondsLabel,
                          onChanged: (value) => controller.setDuration(
                            Duration(seconds: value.round()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('looperPreviewButton'),
                            onPressed: controller.canLoop
                                ? controller.togglePreview
                                : null,
                            icon: Icon(controller.isPlaying
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded),
                            label: Text(controller.isPlaying
                                ? l10n.looperStop
                                : l10n.looperPreview),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('looperExportGifButton'),
                            onPressed: controller.canLoop && !isExporting
                                ? () {
                                    Navigator.of(context).pop();
                                    onExportGif();
                                  }
                                : null,
                            icon: const Icon(Icons.movie_creation_rounded),
                            label: Text(l10n.looperExportGif),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
