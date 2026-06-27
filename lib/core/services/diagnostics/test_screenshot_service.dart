import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/diagnostics/test_logger.dart';

/// Service for capturing screenshots during integration tests.
///
/// Wraps [ExportService.capturePng] with logging and configurable output directory.
class TestScreenshotService {
  TestScreenshotService({required String outputDir}) : _outputDir = outputDir;

  final String _outputDir;
  final ExportService _exportService = const ExportService();
  final TestLogger _logger = TestLogger();

  /// Captures a screenshot of the widget tree under [boundaryKey].
  ///
  /// Saves the PNG to `{outputDir}/{name}.png` and logs the capture.
  ///
  /// Returns the saved [File] on success, or null if capture failed.
  ///
  /// Parameters:
  /// - [boundaryKey]: The GlobalKey of the RepaintBoundary to capture
  /// - [name]: Base filename (without extension) for the screenshot
  /// - [pixelRatio]: Pixel density multiplier (default: 2.0 for high-DPI)
  Future<File?> capture(
    GlobalKey boundaryKey,
    String name, {
    double pixelRatio = 2.0,
  }) async {
    try {
      // Ensure output directory exists
      final dir = Directory(_outputDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filename = _screenshotFilename(name);

      // Capture PNG bytes
      final bytes = await _exportService.capturePng(
        boundaryKey,
        pixelRatio: pixelRatio,
      );

      // Save to file
      final file = File('$_outputDir/$filename');
      await file.writeAsBytes(bytes);

      // Log success
      _logger.logScreenshot(
        name,
        metadata: {
          'path': file.path,
          'size': bytes.length,
        },
      );

      return file;
    } catch (e) {
      // Log failure
      _logger.logAction('screenshot', 'Failed to capture $name: $e');
      return null;
    }
  }

  String _screenshotFilename(String name) {
    if (name.trim().isEmpty) {
      throw StateError('Screenshot name must not be empty.');
    }
    final filename = '$name.png';
    ExportSizePolicy.validateExportFilename(filename);
    return filename;
  }
}
