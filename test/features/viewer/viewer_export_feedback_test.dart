import 'dart:io';

import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_feedback.dart';
import 'package:flutter_fractals/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  ExportResult result({
    ExportFormat format = ExportFormat.png,
    int fileSize = 2048,
  }) {
    return ExportResult(
      file: File('/tmp/fractal.${format.extension}'),
      format: format,
      width: 1920,
      height: 1080,
      fileSize: fileSize,
    );
  }

  group('ViewerExportFeedback', () {
    test('reports normal saved exports as success', () {
      final feedback = ViewerExportFeedback(
        result: result(format: ExportFormat.jpg),
        usedFallback: false,
      );

      expect(feedback.saved, isTrue);
      expect(feedback.shareFailed, isFalse);
      expect(feedback.isWarning, isFalse);
      expect(feedback.title(l10n), 'Export saved');
      expect(feedback.detail(l10n), '1920×1080 • JPG • 2.0 KB');
    });

    test('labels fallback exports truthfully as PNG fallback', () {
      final feedback = ViewerExportFeedback(
        result: result(format: ExportFormat.png),
        usedFallback: true,
      );

      expect(feedback.formatLabel(l10n), 'PNG fallback');
      expect(feedback.detail(l10n), '1920×1080 • PNG fallback • 2.0 KB');
    });

    test('keeps saved exports saved when optional sharing fails', () {
      final feedback = ViewerExportFeedback(
        result: result(),
        usedFallback: false,
        shareError: StateError('share sheet unavailable'),
      );

      expect(feedback.saved, isTrue);
      expect(feedback.shareFailed, isTrue);
      expect(feedback.isWarning, isTrue);
      expect(feedback.title(l10n), startsWith('Export saved.'));
      expect(feedback.detail(l10n), '1920×1080 • PNG • 2.0 KB');
    });
  });
}
