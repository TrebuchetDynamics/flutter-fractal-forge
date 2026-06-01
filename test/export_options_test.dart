import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/export_options.dart';

void main() {
  group('ExportFormat', () {
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
  });

  group('ExportResolution', () {
    test('dimensions returns correct values for preset resolutions', () {
      expect(ExportResolution.hd.dimensions, (1280, 720));
      expect(ExportResolution.fullHd.dimensions, (1920, 1080));
      expect(ExportResolution.quadHd.dimensions, (2560, 1440));
      expect(ExportResolution.uhd4k.dimensions, (3840, 2160));
      expect(ExportResolution.instagram.dimensions, (1080, 1080));
      expect(ExportResolution.instagramStory.dimensions, (1080, 1920));
      expect(ExportResolution.twitter.dimensions, (1200, 675));
    });

    test('screen and custom resolutions return null dimensions', () {
      expect(ExportResolution.screen.dimensions, isNull);
      expect(ExportResolution.custom.dimensions, isNull);
    });

    test('isSocialPreset identifies social presets correctly', () {
      expect(ExportResolution.instagram.isSocialPreset, isTrue);
      expect(ExportResolution.instagramStory.isSocialPreset, isTrue);
      expect(ExportResolution.twitter.isSocialPreset, isTrue);
      expect(ExportResolution.fullHd.isSocialPreset, isFalse);
      expect(ExportResolution.uhd4k.isSocialPreset, isFalse);
    });
  });

  group('ExportOptions', () {
    test('default options have sensible values', () {
      const options = ExportOptions();
      expect(options.format, ExportFormat.png);
      expect(options.resolution, ExportResolution.fullHd);
      expect(options.quality, 95);
      expect(options.embedMetadata, isTrue);
      expect(options.transparentBackground, isFalse);
    });

    test('calculatePixelRatio returns correct ratio for preset resolutions',
        () {
      const options = ExportOptions(resolution: ExportResolution.fullHd);
      // Portrait screen 400x800 -> Full HD adapts to 1080x1920.
      // Ratios: 1080/400 = 2.7, 1920/800 = 2.4 -> max = 2.7
      final ratio = options.calculatePixelRatio(400, 800);
      expect(ratio, closeTo(2.7, 0.1));
    });

    test('calculatePixelRatio is clamped to 8.0 max', () {
      const options = ExportOptions(resolution: ExportResolution.uhd4k);
      // Screen 100x100 -> would need 38.4 ratio, but clamped to 8
      final ratio = options.calculatePixelRatio(100, 100);
      expect(ratio, 8.0);
    });

    test('calculatePixelRatio sanitizes invalid screen dimensions for presets',
        () {
      const options = ExportOptions(resolution: ExportResolution.fullHd);

      expect(options.calculatePixelRatio(-400, -800), 8.0);
    });

    test('getTargetDimensions returns correct dimensions', () {
      const options = ExportOptions(resolution: ExportResolution.instagram);
      final dims = options.getTargetDimensions(400, 800);
      expect(dims, (1080, 1080));
    });

    test('getTargetDimensions adapts preset orientation to screen orientation',
        () {
      const options = ExportOptions(resolution: ExportResolution.fullHd);
      final dims = options.getTargetDimensions(400, 800);
      expect(dims, (1080, 1920));
    });

    test('social preset dimensions preserve platform crop contracts', () {
      const instagramStory = ExportOptions(
        resolution: ExportResolution.instagramStory,
      );
      const twitter = ExportOptions(resolution: ExportResolution.twitter);

      expect(instagramStory.getTargetDimensions(1200, 800), (1080, 1920));
      expect(twitter.getTargetDimensions(400, 800), (1200, 675));
      expect(
        instagramStory.calculatePixelRatio(1200, 800),
        closeTo(2.4, 0.01),
      );
    });

    test('custom resolution uses customWidth and customHeight', () {
      const options = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 2000,
        customHeight: 1500,
      );
      final dims = options.getTargetDimensions(400, 800);
      expect(dims, (2000, 1500));
    });

    test('custom resolution ignores non-positive dimensions', () {
      const options = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 0,
        customHeight: -10,
      );

      expect(options.getTargetDimensions(400, 800), (400, 800));
      expect(options.calculatePixelRatio(400, 800), 1.0);
    });

    test('custom resolution can fall back one axis at a time', () {
      const options = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 2000,
        customHeight: 0,
      );

      expect(options.getTargetDimensions(400, 800), (2000, 800));
      expect(options.calculatePixelRatio(400, 800), 5.0);
    });

    test('screen dimensions used for fallback are at least one pixel', () {
      const options = ExportOptions(resolution: ExportResolution.custom);

      expect(options.getTargetDimensions(0, -20), (1, 1));
      expect(options.calculatePixelRatio(0, -20), 1.0);
    });

    test('copyWith creates new instance with updated values', () {
      const original = ExportOptions();
      final updated = original.copyWith(
        format: ExportFormat.jpg,
        quality: 80,
      );

      expect(updated.format, ExportFormat.jpg);
      expect(updated.quality, 80);
      expect(updated.resolution, original.resolution); // Unchanged
    });

    test('copyWith clears nullable custom dimensions when null is explicit', () {
      const original = ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 2000,
        customHeight: 1500,
      );

      final updated = original.copyWith(
        customWidth: null,
        customHeight: null,
      );

      expect(updated.customWidth, isNull);
      expect(updated.customHeight, isNull);
      expect(updated.getTargetDimensions(400, 800), (400, 800));
    });

    test('copyWith clears nullable provenance fields when null is explicit',
        () {
      final metadata = ExportMetadata(
        fractalType: 'mandelbrot',
        parameters: const {'iterations': 100},
        createdAt: DateTime(2024, 1, 15),
      );
      final original = ExportOptions(
        metadata: metadata,
        watermarkText: 'Flutter Fractals',
      );

      final updated = original.copyWith(
        metadata: null,
        watermarkText: null,
      );

      expect(updated.metadata, isNull);
      expect(updated.watermarkText, isNull);
    });

    test('copyWith omits nullable provenance fields without clearing them', () {
      final metadata = ExportMetadata(
        fractalType: 'mandelbrot',
        parameters: const {'iterations': 100},
        createdAt: DateTime(2024, 1, 15),
      );
      final original = ExportOptions(
        metadata: metadata,
        watermarkText: 'Flutter Fractals',
      );

      final updated = original.copyWith(quality: 80);

      expect(updated.metadata, same(metadata));
      expect(updated.watermarkText, 'Flutter Fractals');
    });
  });

  group('ExportMetadata', () {
    test('toExifMap returns expected keys', () {
      final metadata = ExportMetadata(
        fractalType: 'mandelbrot',
        parameters: const {'iterations': 100},
        createdAt: DateTime(2024, 1, 15),
      );

      final exif = metadata.toExifMap();
      expect(exif, containsPair('Software', contains('Flutter Fractals')));
      expect(exif, containsPair('Artist', 'Flutter Fractals'));
      expect(exif, containsPair('UserComment', contains('mandelbrot')));
    });
  });

  group('ExportPresets', () {
    test('socialShare preset has correct settings', () {
      expect(ExportPresets.socialShare.format, ExportFormat.jpg);
      expect(ExportPresets.socialShare.resolution, ExportResolution.instagram);
      expect(ExportPresets.socialShare.quality, 90);
    });

    test('highQualityPng preset has correct settings', () {
      expect(ExportPresets.highQualityPng.format, ExportFormat.png);
      expect(ExportPresets.highQualityPng.resolution, ExportResolution.uhd4k);
    });

    test('webOptimized preset has correct settings', () {
      expect(ExportPresets.webOptimized.format, ExportFormat.webp);
      expect(ExportPresets.webOptimized.resolution, ExportResolution.fullHd);
      expect(ExportPresets.webOptimized.quality, 85);
    });

    test('transparentOverlay preset has correct settings', () {
      expect(ExportPresets.transparentOverlay.format, ExportFormat.png);
      expect(ExportPresets.transparentOverlay.transparentBackground, isTrue);
    });
  });
}
