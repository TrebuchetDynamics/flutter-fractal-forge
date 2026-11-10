import 'package:flutter/material.dart';

import 'package:flutter_fractals/core/models/video_export_options.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';

/// Minimal UI scaffold for video export.
///
/// The app's video export pipeline lives in [VideoExportService]. This sheet
/// intentionally stays lightweight so the viewer can launch it without build
/// errors even when advanced UI is still evolving.
class VideoExportSheet extends StatelessWidget {
  final VideoExportOptions initialOptions;
  final String fractalType;
  final List<String> availableParameters;
  final Map<String, (double, double)> parameterRanges;
  final ValueChanged<VideoExportOptions> onExport;

  const VideoExportSheet({
    super.key,
    required this.initialOptions,
    required this.fractalType,
    required this.availableParameters,
    required this.parameterRanges,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      maxHeightFactor: 0.85,
      icon: Icons.movie_creation_outlined,
      title: 'Export Video',
      onClose: () => Navigator.of(context).pop(),
      bodyPadding: const EdgeInsets.all(AppSpacing.xl),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video export UI is scaffolded. Tap Export to run with default options.',
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onExport(initialOptions);
              },
              icon: const Icon(Icons.movie_creation_outlined),
              label: const Text('Export'),
            ),
          ),
        ],
      ),
    );
  }
}
