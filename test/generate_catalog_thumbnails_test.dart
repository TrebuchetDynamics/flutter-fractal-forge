// ignore_for_file: avoid_print
/// Generates catalog thumbnail PNGs for all escape-time catalog entries.
///
/// Run with:
///   flutter test test/generate_catalog_thumbnails_test.dart
///
/// Outputs 128x128 PNGs to assets/catalog_thumbs/{id}.png
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

const int _thumbSize = 128;

void main() {
  test('Generate catalog thumbnails', () async {
    final outDir = Directory('assets/catalog_thumbs');
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    int generated = 0;
    int failed = 0;
    final stopwatch = Stopwatch()..start();

    for (final config in escapeTimeCatalog) {
      try {
        final rgba = _renderFractal(
          moduleId: config.id,
          centerX: config.defaultCenterX,
          centerY: config.defaultCenterY,
          zoom: config.defaultZoom,
          iterations: config.defaultIterations.round().clamp(50, 300),
          bailout: config.defaultBailout,
          width: _thumbSize,
          height: _thumbSize,
        );

        // Convert RGBA to PNG via package:image
        final image = img.Image(width: _thumbSize, height: _thumbSize);
        for (int y = 0; y < _thumbSize; y++) {
          for (int x = 0; x < _thumbSize; x++) {
            final idx = (y * _thumbSize + x) * 4;
            image.setPixelRgba(x, y, rgba[idx], rgba[idx + 1], rgba[idx + 2], rgba[idx + 3]);
          }
        }

        final pngBytes = img.encodePng(image, level: 6);
        final outFile = File('${outDir.path}/${config.id}.png');
        outFile.writeAsBytesSync(pngBytes);
        generated++;

        if (generated % 20 == 0) {
          print('  Progress: $generated/${escapeTimeCatalog.length} '
              '(${stopwatch.elapsedMilliseconds}ms)');
        }
      } catch (e) {
        print('  FAIL ${config.id}: $e');
        failed++;
      }
    }

    // Generate thumbnails for custom modules not in escapeTimeCatalog
    final customModules = <({String id, double cx, double cy, double zoom, int iters})>[
      (id: 'julia', cx: 0.0, cy: 0.0, zoom: 1.2, iters: 150),
      (id: 'phoenix', cx: -0.5, cy: 0.0, zoom: 1.0, iters: 120),
    ];
    for (final m in customModules) {
      try {
        final rgba = _renderFractal(
          moduleId: m.id,
          centerX: m.cx,
          centerY: m.cy,
          zoom: m.zoom,
          iterations: m.iters,
          bailout: 4.0,
          width: _thumbSize,
          height: _thumbSize,
        );
        final image = img.Image(width: _thumbSize, height: _thumbSize);
        for (int y = 0; y < _thumbSize; y++) {
          for (int x = 0; x < _thumbSize; x++) {
            final idx = (y * _thumbSize + x) * 4;
            image.setPixelRgba(x, y, rgba[idx], rgba[idx + 1], rgba[idx + 2], rgba[idx + 3]);
          }
        }
        final pngBytes = img.encodePng(image, level: 6);
        File('${outDir.path}/${m.id}.png').writeAsBytesSync(pngBytes);
        generated++;
      } catch (e) {
        print('  FAIL custom ${m.id}: $e');
        failed++;
      }
    }

    stopwatch.stop();
    print('\n=== Thumbnail Generation Complete ===');
    print('Generated: $generated');
    print('Failed: $failed');
    print('Total time: ${stopwatch.elapsedMilliseconds}ms');
    print('Output: ${outDir.path}/');

    // Verify
    final files = outDir.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList();
    print('PNG files on disk: ${files.length}');

    final tooSmall = files.where((f) => f.lengthSync() < 500).toList();
    if (tooSmall.isNotEmpty) {
      print('WARNING: ${tooSmall.length} files < 500 bytes');
    }

    final totalSize = files.fold<int>(0, (sum, f) => sum + f.lengthSync());
    print('Total asset size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');

    expect(generated, greaterThanOrEqualTo(escapeTimeCatalog.length - failed));
    expect(failed, 0);
    expect(files.length, greaterThanOrEqualTo(escapeTimeCatalog.length));
  });
}

/// Pure-Dart CPU fractal renderer (no dart:ui needed).
/// Mirrors the logic in cpu_fractal_renderer.dart but standalone.
Uint8List _renderFractal({
  required String moduleId,
  required double centerX,
  required double centerY,
  required double zoom,
  required int iterations,
  required double bailout,
  required int width,
  required int height,
}) {
  final scale = 3.0 / (zoom <= 0 ? 1.0 : zoom);
  final aspect = width / height;
  final bytes = Uint8List(width * height * 4);
  final bailout2 = bailout * bailout;

  // 2x2 MSAA
  const samplesPerAxis = 2;
  const totalSamples = samplesPerAxis * samplesPerAxis;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double rAcc = 0, gAcc = 0, bAcc = 0;

      for (int sy = 0; sy < samplesPerAxis; sy++) {
        for (int sx = 0; sx < samplesPerAxis; sx++) {
          final subX = (x + (sx + 0.5) / samplesPerAxis) / (width - 1);
          final subY = (y + (sy + 0.5) / samplesPerAxis) / (height - 1);
          final nx = subX * 2.0 - 1.0;
          final ny = subY * 2.0 - 1.0;

          final cx = centerX + nx * scale * aspect;
          final cy = centerY + ny * scale;

          final (r, g, b) = _escapeColor(
            moduleId: moduleId,
            cx: cx,
            cy: cy,
            iterations: iterations,
            bailout2: bailout2,
          );
          rAcc += r;
          gAcc += g;
          bAcc += b;
        }
      }

      final idx = (y * width + x) * 4;
      bytes[idx + 0] = (rAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 1] = (gAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 2] = (bAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 3] = 255;
    }
  }

  return bytes;
}

(double, double, double) _escapeColor({
  required String moduleId,
  required double cx,
  required double cy,
  required int iterations,
  required double bailout2,
}) {
  double zx, zy, c0x, c0y;

  // Julia-like modules use z=point, c=fixed seed
  if (moduleId == 'julia') {
    zx = cx;
    zy = cy;
    c0x = -0.8;
    c0y = 0.156;
  } else {
    zx = 0.0;
    zy = 0.0;
    c0x = cx;
    c0y = cy;
  }

  int it = 0;
  while (it < iterations) {
    final zx2 = zx * zx;
    final zy2 = zy * zy;
    if (zx2 + zy2 > bailout2) break;

    switch (moduleId) {
      case 'burning_ship':
        final rx = zx2 - zy2 + c0x;
        final ry = 2.0 * zx.abs() * zy.abs() + c0y;
        zx = rx;
        zy = ry;
      case 'celtic':
        final rx = (zx2 - zy2).abs() + c0x;
        final ry = 2.0 * zx * zy + c0y;
        zx = rx;
        zy = ry;
      case 'buffalo':
        final rx = (zx2 - zy2).abs() + c0x;
        final ry = (2.0 * zx * zy).abs() + c0y;
        zx = rx;
        zy = ry;
      case 'tricorn':
        final rx = zx2 - zy2 + c0x;
        final ry = -2.0 * zx * zy + c0y;
        zx = rx;
        zy = ry;
      case 'multibrot3':
        // z^3 + c
        final zx3 = zx * zx2 - 3.0 * zx * zy2;
        final zy3 = 3.0 * zx2 * zy - zy * zy2;
        zx = zx3 + c0x;
        zy = zy3 + c0y;
      case 'phoenix':
        final px = zx2 - zy2 + c0x + 0.5667 * (it > 0 ? zx : 0);
        final py = 2.0 * zx * zy + c0y;
        zx = px;
        zy = py;
      default:
        // Standard Mandelbrot iteration z^2 + c
        final rx = zx2 - zy2 + c0x;
        final ry = 2.0 * zx * zy + c0y;
        zx = rx;
        zy = ry;
    }
    it++;
  }

  if (it >= iterations) {
    return (18, 18, 28); // Dark interior
  }

  final mag2 = math.max(1e-16, zx * zx + zy * zy);
  final smooth =
      it + 1.0 - math.log(math.log(mag2) / math.log(2.0)) / math.log(2.0);
  final t = (smooth / math.max(1, iterations)).clamp(0.0, 1.0);
  return _palette(t, moduleId.hashCode);
}

/// Cosine palette with per-module color variation based on id hash.
(double, double, double) _palette(double t, int hash) {
  // Vary phase offsets per module so different fractals get different color schemes
  final p0 = (hash.abs() % 100) / 100.0;
  final p1 = ((hash.abs() ~/ 100) % 100) / 100.0;
  final p2 = ((hash.abs() ~/ 10000) % 100) / 100.0;

  final r = (0.5 + 0.5 * math.cos(6.28318 * (t + p0))) * 255.0;
  final g = (0.5 + 0.5 * math.cos(6.28318 * (t + p1))) * 255.0;
  final b = (0.5 + 0.5 * math.cos(6.28318 * (t + p2))) * 255.0;
  return (r, g, b);
}
