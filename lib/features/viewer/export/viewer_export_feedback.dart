import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Immutable contract for what the viewer should tell the user after export.
///
/// Export has two phases from the user's point of view:
/// 1. required capture/save
/// 2. optional share sheet launch
///
/// A failure in phase 2 must never rewrite a completed save as an export
/// failure. This keeps snackbars, tests, and future export surfaces aligned.
final class ViewerExportFeedback {
  const ViewerExportFeedback({
    required this.result,
    required this.usedFallback,
    this.shareError,
  });

  final ExportResult result;
  final bool usedFallback;
  final Object? shareError;

  bool get saved => true;
  bool get shareFailed => shareError != null;
  bool get isWarning => shareFailed;

  String formatLabel(AppLocalizations l10n) {
    if (usedFallback || result.format == ExportFormat.webp) {
      return l10n.exportFormatFallbackPng;
    }
    return result.format.displayName;
  }

  String title(AppLocalizations l10n) {
    if (shareFailed) {
      return l10n.exportSavedShareFailed;
    }
    return l10n.exportSaved;
  }

  String detail(AppLocalizations l10n) {
    return '${result.resolution} • ${formatLabel(l10n)} • ${result.formattedSize}';
  }
}
