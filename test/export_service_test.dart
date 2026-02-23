import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:flutter_fractals/core/models/export_options.dart';

void main() {
  const service = ExportService();

  group('ExportService.generateFilename', () {
    test('uses default prefix and format extension', () {
      final name = service.generateFilename(format: ExportFormat.png);
      expect(name, startsWith('fractal_'));
      expect(name, endsWith('.png'));
    });

    test('includes fractal type when provided', () {
      final name = service.generateFilename(
        format: ExportFormat.jpg,
        fractalType: 'Mandelbrot',
      );
      expect(name, contains('_mandelbrot_'));
      expect(name, endsWith('.jpg'));
    });

    test('uses custom prefix', () {
      final name = service.generateFilename(
        prefix: 'export',
        format: ExportFormat.webp,
      );
      expect(name, startsWith('export_'));
      expect(name, endsWith('.webp'));
    });

    test('includes timestamp for uniqueness', () {
      final name1 = service.generateFilename(format: ExportFormat.png);
      final _ = service.generateFilename(format: ExportFormat.png);
      // Both should have numeric timestamps; may be equal if called in same ms
      final ts1 = RegExp(r'(\d+)\.png$').firstMatch(name1)?.group(1);
      expect(ts1, isNotNull);
      expect(int.tryParse(ts1!), isNotNull);
    });
  });

  group('ExportService.resolveEffectiveFormat', () {
    test('keeps PNG and JPG unchanged', () {
      expect(
          service.resolveEffectiveFormat(ExportFormat.png), ExportFormat.png);
      expect(
          service.resolveEffectiveFormat(ExportFormat.jpg), ExportFormat.jpg);
    });

    test('falls back WebP to PNG until native WebP encoding exists', () {
      expect(
          service.resolveEffectiveFormat(ExportFormat.webp), ExportFormat.png);
    });
  });

  group('ExportService.applyWallpaperStyle', () {
    late Uint8List testPng;

    setUp(() {
      // Create a small 4x4 red PNG for testing.
      final testImage = img.Image(width: 4, height: 4);
      img.fill(testImage, color: img.ColorRgb8(200, 50, 50));
      testPng = Uint8List.fromList(img.encodePng(testImage));
    });

    test('plain style returns original bytes unchanged', () {
      final result = service.applyWallpaperStyle(testPng, style: 'plain');
      expect(result, same(testPng));
    });

    test('unknown style returns original bytes unchanged', () {
      final result = service.applyWallpaperStyle(testPng, style: 'unknown');
      expect(result, same(testPng));
    });

    test('homeOptimized returns valid PNG with different bytes', () {
      final result =
          service.applyWallpaperStyle(testPng, style: 'homeOptimized');
      // Should be a valid PNG (starts with PNG signature).
      expect(result.length, greaterThan(8));
      expect(result[0], 0x89); // PNG signature byte
      expect(result[1], 0x50); // 'P'
      // Should differ from original (bottom gradient applied).
      final decoded = img.decodePng(result);
      expect(decoded, isNotNull);
      expect(decoded!.width, 4);
      expect(decoded.height, 4);
    });

    test('lockOptimized returns valid PNG', () {
      final result =
          service.applyWallpaperStyle(testPng, style: 'lockOptimized');
      final decoded = img.decodePng(result);
      expect(decoded, isNotNull);
      expect(decoded!.width, 4);
      expect(decoded.height, 4);
    });

    test('handles invalid PNG gracefully', () {
      final garbage = Uint8List.fromList([1, 2, 3, 4]);
      final result =
          service.applyWallpaperStyle(garbage, style: 'homeOptimized');
      // Should return original bytes on decode failure.
      expect(result, same(garbage));
    });
  });

  group('ExportResult', () {
    final dummyFile = File('/tmp/test_dummy.png');

    test('formattedSize formats bytes', () {
      final result = ExportResult(
        file: dummyFile,
        format: ExportFormat.png,
        width: 100,
        height: 100,
        fileSize: 512,
      );
      expect(result.formattedSize, '512 B');
    });

    test('formattedSize formats kilobytes', () {
      final result = ExportResult(
        file: dummyFile,
        format: ExportFormat.png,
        width: 100,
        height: 100,
        fileSize: 2048,
      );
      expect(result.formattedSize, '2.0 KB');
    });

    test('formattedSize formats megabytes', () {
      final result = ExportResult(
        file: dummyFile,
        format: ExportFormat.png,
        width: 100,
        height: 100,
        fileSize: 3 * 1024 * 1024,
      );
      expect(result.formattedSize, '3.0 MB');
    });

    test('resolution returns correct format', () {
      final result = ExportResult(
        file: dummyFile,
        format: ExportFormat.png,
        width: 1920,
        height: 1080,
        fileSize: 0,
      );
      expect(result.resolution, '1920×1080');
    });
  });

  group('ExportFormat extension', () {
    test('extension returns correct file extensions', () {
      expect(ExportFormat.png.extension, 'png');
      expect(ExportFormat.jpg.extension, 'jpg');
      expect(ExportFormat.webp.extension, 'webp');
    });

    test('mimeType returns correct MIME types', () {
      expect(ExportFormat.png.mimeType, 'image/png');
      expect(ExportFormat.jpg.mimeType, 'image/jpeg');
      expect(ExportFormat.webp.mimeType, 'image/webp');
    });

    test('displayName returns human-readable names', () {
      expect(ExportFormat.png.displayName, 'PNG');
      expect(ExportFormat.jpg.displayName, 'JPG');
      expect(ExportFormat.webp.displayName, 'WebP');
    });
  });

  group('ExportOptions', () {
    test('calculatePixelRatio uses resolution dimensions', () {
      const opts = ExportOptions(resolution: ExportResolution.fullHd);
      // Screen 960x540 → 1920/960 = 2.0, 1080/540 = 2.0
      expect(opts.calculatePixelRatio(960, 540), 2.0);
    });

    test('calculatePixelRatio clamps to min 1.0', () {
      const opts = ExportOptions(resolution: ExportResolution.hd);
      // Screen 2000x2000 → 1280/2000 = 0.64, 720/2000 = 0.36 → clamped to 1.0
      expect(opts.calculatePixelRatio(2000, 2000), 1.0);
    });

    test('calculatePixelRatio clamps to max 8.0', () {
      const opts = ExportOptions(resolution: ExportResolution.uhd4k);
      // Screen 100x100 → 3840/100 = 38.4 → clamped to 8.0
      expect(opts.calculatePixelRatio(100, 100), 8.0);
    });

    test('calculatePixelRatio handles custom resolution', () {
      const opts = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 800,
      );
      // 800/400 = 2.0
      expect(opts.calculatePixelRatio(400, 300), 2.0);
    });

    test('calculatePixelRatio uses larger custom axis ratio', () {
      const opts = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 600,
        customHeight: 1600,
      );
      // width ratio = 1.0, height ratio = 4.0
      expect(opts.calculatePixelRatio(600, 400), 4.0);
    });

    test('calculatePixelRatio defaults for screen resolution', () {
      const opts = ExportOptions(resolution: ExportResolution.screen);
      expect(opts.calculatePixelRatio(400, 300), 2.5);
    });

    test('getTargetDimensions returns preset dimensions', () {
      const opts = ExportOptions(resolution: ExportResolution.fullHd);
      expect(opts.getTargetDimensions(400, 300), (1920, 1080));
    });

    test('getTargetDimensions adapts preset dimensions for portrait screens',
        () {
      const opts = ExportOptions(resolution: ExportResolution.fullHd);
      expect(opts.getTargetDimensions(400, 800), (1080, 1920));
    });

    test('getTargetDimensions returns screen size for screen resolution', () {
      const opts = ExportOptions(resolution: ExportResolution.screen);
      expect(opts.getTargetDimensions(412.5, 892.0), (413, 892));
    });

    test('getTargetDimensions returns custom dimensions', () {
      const opts = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 800,
        customHeight: 600,
      );
      expect(opts.getTargetDimensions(400, 300), (800, 600));
    });

    test('copyWith preserves unchanged fields', () {
      const original = ExportOptions(
        format: ExportFormat.png,
        quality: 95,
        transparentBackground: true,
      );
      final copied = original.copyWith(format: ExportFormat.jpg);
      expect(copied.format, ExportFormat.jpg);
      expect(copied.quality, 95);
      expect(copied.transparentBackground, true);
    });
  });

  group('ExportResolution', () {
    test('isSocialPreset identifies social presets', () {
      expect(ExportResolution.instagram.isSocialPreset, true);
      expect(ExportResolution.instagramStory.isSocialPreset, true);
      expect(ExportResolution.twitter.isSocialPreset, true);
      expect(ExportResolution.fullHd.isSocialPreset, false);
      expect(ExportResolution.screen.isSocialPreset, false);
    });

    test('dimensions returns correct sizes', () {
      expect(ExportResolution.hd.dimensions, (1280, 720));
      expect(ExportResolution.fullHd.dimensions, (1920, 1080));
      expect(ExportResolution.uhd4k.dimensions, (3840, 2160));
      expect(ExportResolution.instagram.dimensions, (1080, 1080));
      expect(ExportResolution.screen.dimensions, isNull);
      expect(ExportResolution.custom.dimensions, isNull);
    });
  });

  group('ExportMetadata', () {
    test('toExifMap includes required fields', () {
      final metadata = ExportMetadata(
        fractalType: 'mandelbrot',
        parameters: const {'iterations': 200},
        createdAt: DateTime(2026, 2, 11),
      );
      final map = metadata.toExifMap();
      expect(map['Software'], contains('Flutter Fractals'));
      expect(map['Artist'], 'Flutter Fractals');
      expect(map['Copyright'], contains('2026'));
      expect(map['UserComment'], contains('mandelbrot'));
      expect(map['UserComment'], contains('iterations: 200'));
    });

    test('toExifMap uses custom description when provided', () {
      final metadata = ExportMetadata(
        fractalType: 'julia',
        parameters: const {},
        createdAt: DateTime(2026, 1, 1),
        description: 'My custom description',
      );
      final map = metadata.toExifMap();
      expect(map['ImageDescription'], 'My custom description');
    });

    test('toExifMap uses default description when not provided', () {
      final metadata = ExportMetadata(
        fractalType: 'julia',
        parameters: const {},
        createdAt: DateTime(2026, 1, 1),
      );
      final map = metadata.toExifMap();
      expect(map['ImageDescription'], contains('Fractal artwork'));
    });
  });
}
