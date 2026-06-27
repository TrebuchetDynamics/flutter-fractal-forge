import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';

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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final seconds = controller.duration.inSeconds;
        return Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.loop_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Camera looper',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Save camera + parameter keyframes, then preview or export a looping GIF. Max 15s.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('looperSetAButton'),
                        onPressed: controller.setAFromCurrent,
                        icon: Icon(controller.a == null
                            ? Icons.looks_one_outlined
                            : Icons.check_circle_rounded),
                        label: const Text('Set A'),
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
                        label: const Text('Set B'),
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
                        label:
                            Text('Update ${LooperController.labelForIndex(i)}'),
                        onPressed: () => controller.setPointFromCurrent(i),
                        onDeleted: () => controller.removePoint(i),
                      ),
                    if (controller.points.length >= 2)
                      ActionChip(
                        key: const ValueKey('looperAddPointButton'),
                        avatar: const Icon(Icons.add_rounded),
                        label: Text(
                          'Add ${LooperController.labelForIndex(controller.points.length)}',
                        ),
                        onPressed: controller.addPointFromCurrent,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Text('Duration'),
                    const Spacer(),
                    Text('${seconds}s / 15s max'),
                  ],
                ),
                Slider(
                  key: const ValueKey('looperDurationSlider'),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  value: seconds.toDouble().clamp(1, 15),
                  label: '${seconds}s',
                  onChanged: (value) => controller.setDuration(
                    Duration(seconds: value.round()),
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
                        label: Text(controller.isPlaying ? 'Stop' : 'Preview'),
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
                        label: const Text('Export GIF'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
