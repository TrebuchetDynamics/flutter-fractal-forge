import 'package:flutter_fractals/core/models/export_options.dart';

/// User intent selected from the export sheet.
enum ExportAction {
  saveOnly,
  saveAndShare,
  setWallpaper,
}

/// Immutable payload returned by the export sheet.
class ExportSheetSubmission {
  final ExportOptions options;
  final ExportAction action;

  const ExportSheetSubmission({
    required this.options,
    required this.action,
  });
}

/// Platform/action policy for export UI controls.
class ExportActionAvailability {
  const ExportActionAvailability._();

  static bool canSaveAndShare({required bool isWeb}) => !isWeb;

  static bool canSetWallpaper({required bool isWeb}) => !isWeb;
}
