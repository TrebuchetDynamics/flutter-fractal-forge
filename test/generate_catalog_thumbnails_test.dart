// ignore_for_file: avoid_print
/// Generates catalog thumbnail PNGs for all escape-time catalog entries.
///
/// Run with:
///   flutter test test/generate_catalog_thumbnails_test.dart
///
/// Outputs 128x128 PNGs to assets/catalog_thumbs/{id}.png
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart' show Vector2;

import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';

const int _thumbSize = 320;

void main() {
  test('Generate catalog thumbnails (manual)', () async {
    final outDir = Directory('assets/catalog_thumbs');
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    int generated = 0;
    int failed = 0;
    final stopwatch = Stopwatch()..start();

    for (final config in escapeTimeCatalog) {
      try {
        final frame = await renderCpuFrame(
          moduleId: config.id,
          viewPan: Vector2(config.defaultCenterX, config.defaultCenterY),
          viewZoom: config.defaultZoom,
          iterations: config.defaultIterations.round().clamp(50, 300),
          bailout: config.defaultBailout,
          juliaC: Vector2(-0.8, 0.156),
          width: _thumbSize,
          height: _thumbSize,
          sampleCount: 8,
        );
        final rgba = frame.rgba;

        // Convert RGBA to PNG via package:image
        final image = img.Image(width: _thumbSize, height: _thumbSize);
        for (int y = 0; y < _thumbSize; y++) {
          for (int x = 0; x < _thumbSize; x++) {
            final idx = (y * _thumbSize + x) * 4;
            image.setPixelRgba(
              x,
              y,
              rgba[idx],
              rgba[idx + 1],
              rgba[idx + 2],
              rgba[idx + 3],
            );
          }
        }

        final pngBytes = img.encodePng(image, level: 6);
        final outFile = File('${outDir.path}/${config.id}.png');
        outFile.writeAsBytesSync(pngBytes);
        generated++;

        if (generated % 20 == 0) {
          print(
            '  Progress: $generated/${escapeTimeCatalog.length} (${stopwatch.elapsedMilliseconds}ms)',
          );
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
      (id: 'nova', cx: 0.0, cy: 0.0, zoom: 1.0, iters: 100),
    ];
    for (final m in customModules) {
      try {
        final frame = await renderCpuFrame(
          moduleId: m.id,
          viewPan: Vector2(m.cx, m.cy),
          viewZoom: m.zoom,
          iterations: m.iters,
          bailout: 4.0,
          juliaC: Vector2(-0.8, 0.156),
          width: _thumbSize,
          height: _thumbSize,
          sampleCount: 8,
        );
        final rgba = frame.rgba;

        final image = img.Image(width: _thumbSize, height: _thumbSize);
        for (int y = 0; y < _thumbSize; y++) {
          for (int x = 0; x < _thumbSize; x++) {
            final idx = (y * _thumbSize + x) * 4;
            image.setPixelRgba(
              x,
              y,
              rgba[idx],
              rgba[idx + 1],
              rgba[idx + 2],
              rgba[idx + 3],
            );
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
    final files = outDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList();
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
  }, skip: 'Manual utility test: generates PNGs into assets/catalog_thumbs; not meant for CI.');
}
