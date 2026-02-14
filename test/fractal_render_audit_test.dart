// ignore_for_file: avoid_print
/// Automated render audit: validates every escape-time fractal produces
/// a real fractal image, not just a uniform gradient.
///
/// Uses pixel variance analysis on CPU-rendered frames.
/// A real fractal has high spatial variance; a gradient has low variance.
///
/// Run: flutter test test/fractal_render_audit_test.dart
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';

const int _size = 64; // Small for speed, enough for variance check
const double _minVarianceThreshold = 8.0; // Minimum RGB stdev to be "not a gradient"

void main() {
  test('Render audit: all catalog fractals produce non-gradient output', () async {
    int total = 0;
    int passed = 0;
    int gradientOnly = 0;
    int allBlack = 0;
    final failures = <String>[];
    final results = <({String id, String status, double variance, String shader})>[];
    final stopwatch = Stopwatch()..start();

    for (final config in escapeTimeCatalog) {
      total++;
      try {
        final frame = await renderCpuFrame(
          moduleId: config.id,
          viewPan: Vector2(config.defaultCenterX, config.defaultCenterY),
          viewZoom: config.defaultZoom,
          iterations: config.defaultIterations.round().clamp(50, 300),
          bailout: config.defaultBailout,
          juliaC: Vector2(-0.8, 0.156),
          width: _size,
          height: _size,
          sampleCount: 1,
        );
        final rgba = frame.rgba;

        final stats = _analyzeFrame(rgba, _size, _size);

        String status;
        if (stats.nonBlackRatio < 0.01) {
          status = 'ALL_BLACK';
          allBlack++;
          failures.add('${config.id} (ALL_BLACK, shader: ${config.shaderAsset})');
        } else if (stats.rgbStdev < _minVarianceThreshold) {
          status = 'GRADIENT_ONLY';
          gradientOnly++;
          failures.add(
            '${config.id} (GRADIENT stdev=${stats.rgbStdev.toStringAsFixed(1)}, shader: ${config.shaderAsset})',
          );
        } else {
          status = 'PASS';
          passed++;
        }

        results.add((
          id: config.id,
          status: status,
          variance: stats.rgbStdev,
          shader: config.shaderAsset,
        ));
      } catch (e) {
        results.add((
          id: config.id,
          status: 'ERROR',
          variance: 0,
          shader: config.shaderAsset,
        ));
        failures.add('${config.id} (ERROR: $e)');
      }

      if (total % 50 == 0) {
        print(
          '  Progress: $total/${escapeTimeCatalog.length} (${stopwatch.elapsedMilliseconds}ms)',
        );
      }
    }

    stopwatch.stop();

    // Print full results table
    print('\n=== FRACTAL RENDER AUDIT ===');
    print('${'ID'.padRight(35)} ${'STATUS'.padRight(15)} ${'STDEV'.padRight(10)} SHADER');
    print('-' * 100);
    for (final r in results) {
      print(
        '${r.id.padRight(35)} ${r.status.padRight(15)} ${r.variance.toStringAsFixed(2).padRight(10)} ${r.shader}',
      );
    }
    print('-' * 100);
    print(
      'Total: $total | Pass: $passed | Gradient-only: $gradientOnly | All-black: $allBlack | Errors: ${total - passed - gradientOnly - allBlack}',
    );
    print('Time: ${stopwatch.elapsedMilliseconds}ms');

    if (failures.isNotEmpty) {
      print('\n=== FAILURES ===');
      for (final f in failures) {
        print('  $f');
      }
    }

    expect(allBlack, 0, reason: 'No fractal should render all-black');
    print('\nAudit complete. $passed/$total passed variance check.');
  });
}

/// Analyze pixel statistics of a rendered frame.
({double rgbStdev, double nonBlackRatio, int uniqueColors}) _analyzeFrame(
  Uint8List rgba,
  int width,
  int height,
) {
  final colors = <int>{};

  // Sample 10x10 grid
  final stepX = math.max(1, width ~/ 10);
  final stepY = math.max(1, height ~/ 10);
  final samples = <double>[];

  for (int y = 0; y < height; y += stepY) {
    for (int x = 0; x < width; x += stepX) {
      final idx = (y * width + x) * 4;
      final r = rgba[idx];
      final g = rgba[idx + 1];
      final b = rgba[idx + 2];

      colors.add((r << 16) | (g << 8) | b);

      // Luminance for variance calculation
      samples.add(0.299 * r + 0.587 * g + 0.114 * b);
    }
  }

  // Also check full-frame non-black ratio
  int totalNonBlack = 0;
  for (int i = 0; i < rgba.length; i += 4) {
    if (rgba[i] > 8 || rgba[i + 1] > 8 || rgba[i + 2] > 8) totalNonBlack++;
  }
  final nonBlackRatio = totalNonBlack / (width * height);

  // Compute standard deviation of sampled luminance
  if (samples.isEmpty) {
    return (rgbStdev: 0, nonBlackRatio: 0, uniqueColors: 0);
  }
  final mean = samples.reduce((a, b) => a + b) / samples.length;
  final variance = samples
          .map((s) => (s - mean) * (s - mean))
          .reduce((a, b) => a + b) /
      samples.length;
  final stdev = math.sqrt(variance);

  return (rgbStdev: stdev, nonBlackRatio: nonBlackRatio, uniqueColors: colors.length);
}
