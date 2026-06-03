import 'package:flutter_fractals/core/models/export_options.dart';

/// Replayable display contract for export resolution summaries.
///
/// The export model may orient non-social presets to the current screen before
/// capture. Summary text must use that same target-dimension path instead of
/// raw preset metadata, otherwise portrait exports can be shown as landscape.
final class ExportResolutionSummary {
  final int? width;
  final int? height;
  final bool usesScreenResolution;

  const ExportResolutionSummary._({
    required this.width,
    required this.height,
    required this.usesScreenResolution,
  });

  factory ExportResolutionSummary.fromEffectiveOptions({
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
  }) {
    if (options.resolution == ExportResolution.screen) {
      return const ExportResolutionSummary._(
        width: null,
        height: null,
        usesScreenResolution: true,
      );
    }

    final (width, height) = options.getTargetDimensions(
      screenWidth,
      screenHeight,
    );
    return ExportResolutionSummary._(
      width: width,
      height: height,
      usesScreenResolution: false,
    );
  }

  String label({required String screenResolutionLabel}) {
    if (usesScreenResolution) return screenResolutionLabel;
    return '$width×$height';
  }
}
