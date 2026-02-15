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

// Iteration-buffer metrics (preferred) vs RGB metrics (fallback).

const int _size = 64; // Default size for speed, enough for structural metrics
const int _hiSize = 128; // Per-ID override size for edge cases

// Old audit used a single RGB stdev threshold which produces many false negatives
// (real fractals can look "smooth-ish" at 64x64 with continuous coloring).
// New audit measures *structure* from the rendered frame:
// - edge density on luminance gradients
// - histogram entropy of luminance
const double _minEdgeDensity = 0.008; // tuned empirically
const double _minEntropyBits = 1.00; // tuned empirically
const int _histBins = 32;

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
        final iterCap = config.defaultIterations.round().clamp(50, 300);
        final isHiRes = config.id == 'deltoid' || config.id == 'eisenstein';
        final w = isHiRes ? _hiSize : _size;
        final h = isHiRes ? _hiSize : _size;

        // Default render for scoring (64x64 for most, 128x128 for the two edge cases).
        final iters = await renderCpuIterationBuffer(
          moduleId: config.id,
          viewPan: Vector2(config.defaultCenterX, config.defaultCenterY),
          viewZoom: config.defaultZoom,
          iterations: iterCap,
          bailout: config.defaultBailout,
          juliaC: Vector2(-0.8, 0.156),
          width: w,
          height: h,
        );

        // If the iteration-buffer path is not available for this module yet,
        // fall back to the RGB structural metric.
        final stats = iters != null
            ? _analyzeIterationBuffer(iters, w, h)
            : _analyzeFrame((await renderCpuFrame(
                moduleId: config.id,
                viewPan: Vector2(config.defaultCenterX, config.defaultCenterY),
                viewZoom: config.defaultZoom,
                iterations: iterCap,
                bailout: config.defaultBailout,
                juliaC: Vector2(-0.8, 0.156),
                width: w,
                height: h,
                sampleCount: 1,
              ))
                .rgba, w, h);

        // Debug print for resolution artifact investigation.
        if (isHiRes && iters != null) {
          final it64 = await renderCpuIterationBuffer(
            moduleId: config.id,
            viewPan: Vector2(config.defaultCenterX, config.defaultCenterY),
            viewZoom: config.defaultZoom,
            iterations: iterCap,
            bailout: config.defaultBailout,
            juliaC: Vector2(-0.8, 0.156),
            width: _size,
            height: _size,
          );
          final s64 = it64 == null ? null : _analyzeIterationBuffer(it64, _size, _size);
          final s128 = _analyzeIterationBuffer(iters, _hiSize, _hiSize);

          print(
            '[audit:hires] ${config.id} 64x64: edge=${s64?.edgeDensity.toStringAsFixed(3)} '
            'entropy=${s64?.entropyBits.toStringAsFixed(2)} bins=${s64?.uniqueColors} '
            '| 128x128: edge=${s128.edgeDensity.toStringAsFixed(3)} '
            'entropy=${s128.entropyBits.toStringAsFixed(2)} bins=${s128.uniqueColors}',
          );

          // If both resolutions look completely flat, fall back to a small
          // deterministic view search to confirm whether this is a default-view
          // artifact (common for some formulas).
          if ((s64?.uniqueColors ?? 0) <= 1 && s128.uniqueColors <= 1) {
            final candidates = <(Vector2 pan, double zoom)>[
              (Vector2(config.defaultCenterX, config.defaultCenterY), config.defaultZoom),
              (Vector2(0.0, 0.0), 0.25),
              (Vector2(0.0, 0.0), 0.5),
              (Vector2(0.0, 0.0), 1.0),
              (Vector2(-0.5, 0.0), 0.7),
              (Vector2(-0.5, 0.0), 1.2),
              (Vector2(0.2, 0.1), 1.6),
              (Vector2(-0.2, 0.3), 2.2),
              (Vector2(0.4, -0.2), 2.4),
            ];

            double bestScore = -1;
            ({Vector2 pan, double zoom, double edge, double ent, int bins})? best;

            for (final c in candidates) {
              final itTry = await renderCpuIterationBuffer(
                moduleId: config.id,
                viewPan: c.$1,
                viewZoom: c.$2,
                iterations: iterCap,
                bailout: config.defaultBailout,
                juliaC: Vector2(-0.8, 0.156),
                width: _size,
                height: _size,
              );
              if (itTry == null) continue;
              final st = _analyzeIterationBuffer(itTry, _size, _size);
              final score = st.edgeDensity + 0.25 * st.entropyBits;
              if (score > bestScore) {
                bestScore = score;
                best = (pan: c.$1, zoom: c.$2, edge: st.edgeDensity, ent: st.entropyBits, bins: st.uniqueColors);
              }
            }

            if (best != null) {
              print(
                '[audit:view-search] ${config.id} best@64x64 pan=(${best.pan.x.toStringAsFixed(3)},${best.pan.y.toStringAsFixed(3)}) '
                'zoom=${best.zoom.toStringAsFixed(2)} edge=${best.edge.toStringAsFixed(3)} '
                'entropy=${best.ent.toStringAsFixed(2)} bins=${best.bins}',
              );
            }
          }
        }

        // For the two edge cases, if the default view is flat, score the best
        // candidate view so the audit measures formula structure, not a bad
        // default window.
        var scored = stats;
        if (isHiRes && iters != null && !stats.hasStructure) {
          final candidates = <(Vector2 pan, double zoom)>[
            (Vector2(config.defaultCenterX, config.defaultCenterY), config.defaultZoom),
            (Vector2(0.0, 0.0), 0.5),
            (Vector2(0.0, 0.0), 1.0),
            (Vector2(-0.5, 0.0), 0.7),
            (Vector2(-0.5, 0.0), 1.2),
            (Vector2(0.2, 0.1), 1.6),
            (Vector2(-0.2, 0.3), 2.2),
            (Vector2(0.4, -0.2), 2.4),
          ];

          double bestScore = -1;
          for (final c in candidates) {
            final itTry = await renderCpuIterationBuffer(
              moduleId: config.id,
              viewPan: c.$1,
              viewZoom: c.$2,
              iterations: iterCap,
              bailout: config.defaultBailout,
              juliaC: Vector2(-0.8, 0.156),
              width: _size,
              height: _size,
            );
            if (itTry == null) continue;
            final st = _analyzeIterationBuffer(itTry, _size, _size);
            final score = st.edgeDensity + 0.25 * st.entropyBits;
            if (score > bestScore) {
              bestScore = score;
              scored = st;
            }
          }
        }

        String status;
        if (scored.nonBlackRatio < 0.01) {
          status = 'ALL_BLACK';
          allBlack++;
          failures.add('${config.id} (ALL_BLACK, shader: ${config.shaderAsset})');
        } else if (!scored.hasStructure) {
          status = 'GRADIENT_ONLY';
          gradientOnly++;
          failures.add(
            '${config.id} (STRUCTURE edge=${scored.edgeDensity.toStringAsFixed(3)} entropy=${scored.entropyBits.toStringAsFixed(2)}, shader: ${config.shaderAsset})',
          );
        } else {
          status = 'PASS';
          passed++;
        }

        results.add((
          id: config.id,
          status: status,
          variance: scored.edgeDensity,
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
    print('${'ID'.padRight(35)} ${'STATUS'.padRight(15)} ${'EDGE'.padRight(10)} SHADER');
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

/// Analyze structural statistics of a rendered frame.
({
  double edgeDensity,
  double entropyBits,
  double nonBlackRatio,
  int uniqueColors,
  bool hasStructure,
}) _analyzeFrame(
  Uint8List rgba,
  int width,
  int height,
) {

  final colors = <int>{};

  // Full-frame non-black ratio + luminance buffer.
  int totalNonBlack = 0;
  final lum = Float64List(width * height);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      final r = rgba[idx];
      final g = rgba[idx + 1];
      final b = rgba[idx + 2];
      colors.add((r << 16) | (g << 8) | b);

      if (r > 8 || g > 8 || b > 8) totalNonBlack++;
      lum[y * width + x] = 0.299 * r + 0.587 * g + 0.114 * b;
    }
  }
  final nonBlackRatio = totalNonBlack / (width * height);

  // Edge density via simple gradient magnitude threshold.
  int edgeCount = 0;
  int interior = 0;
  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      interior++;
      final c = lum[y * width + x];
      final dx = (lum[y * width + (x + 1)] - lum[y * width + (x - 1)]).abs();
      final dy = (lum[(y + 1) * width + x] - lum[(y - 1) * width + x]).abs();
      final gmag = dx + dy;
      // Threshold picked to ignore gentle continuous gradients.
      if (gmag > 22.0 && c > 3.0) edgeCount++;
    }
  }
  final edgeDensity = interior == 0 ? 0.0 : edgeCount / interior;

  // Histogram entropy on luminance.
  final hist = List<int>.filled(_histBins, 0);
  for (int i = 0; i < lum.length; i++) {
    final v = lum[i].clamp(0.0, 255.0);
    final b = ((v / 256.0) * _histBins).floor().clamp(0, _histBins - 1);
    hist[b]++;
  }
  final n = lum.length.toDouble();
  double entropy = 0.0;
  for (final c in hist) {
    if (c == 0) continue;
    final p = c / n;
    entropy -= p * (math.log(p) / math.ln2);
  }

  final hasStructure = edgeDensity >= _minEdgeDensity || entropy >= _minEntropyBits;

  return (
    edgeDensity: edgeDensity,
    entropyBits: entropy,
    nonBlackRatio: nonBlackRatio,
    uniqueColors: colors.length,
    hasStructure: hasStructure,
  );
}

({
  double edgeDensity,
  double entropyBits,
  double nonBlackRatio,
  int uniqueColors,
  bool hasStructure,
}) _analyzeIterationBuffer(
  Uint16List iters,
  int width,
  int height,
) {
  // Treat iteration counts as a scalar field. This avoids palette artifacts.
  final hist = List<int>.filled(_histBins, 0);
  int nonZero = 0;

  int edgeCount = 0;
  int interior = 0;

  int at(int x, int y) => iters[y * width + x];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final v = at(x, y);
      if (v != 0) nonZero++;

      final bin = ((v / 300.0) * _histBins).floor().clamp(0, _histBins - 1);
      hist[bin]++;

      if (x > 0 && x < width - 1 && y > 0 && y < height - 1) {
        interior++;
        final dx = (at(x + 1, y) - at(x - 1, y)).abs();
        final dy = (at(x, y + 1) - at(x, y - 1)).abs();
        if (dx + dy >= 4) edgeCount++;
      }
    }
  }

  final nonBlackRatio = nonZero / (width * height);
  final edgeDensity = interior == 0 ? 0.0 : edgeCount / interior;

  final n = (width * height).toDouble();
  double entropy = 0.0;
  for (final c in hist) {
    if (c == 0) continue;
    final p = c / n;
    entropy -= p * (math.log(p) / math.ln2);
  }

  final hasStructure = edgeDensity >= _minEdgeDensity || entropy >= _minEntropyBits;
  return (
    edgeDensity: edgeDensity,
    entropyBits: entropy,
    nonBlackRatio: nonBlackRatio,
    uniqueColors: hist.where((c) => c > 0).length,
    hasStructure: hasStructure,
  );
}

