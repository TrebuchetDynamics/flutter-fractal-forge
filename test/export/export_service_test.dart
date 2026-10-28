import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/export/export_coordinator.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/export/export_worker.dart';
import 'package:flutter_fractals/core/services/export/share_service.dart';
import 'package:flutter_fractals/core/models/export_options.dart';

/// Minimal fake that satisfies PathProviderPlatform for unit tests.
class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempDir;
  _FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir;

  @override
  Future<String?> getTemporaryPath() async => tempDir;
}

class _RecordingExportWorker implements ExportWorker {
  int calls = 0;

  @override
  Future<T> run<T>(
    ExportWorkerTask<T> task, {
    ExportCancellationToken? token,
    void Function()? onSpawned,
  }) async {
    calls++;
    token?.throwIfCancelled();
    return await task();
  }
}

class _FaultingExportFileOperations implements ExportFileOperations {
  final bool failWrite;
  final bool failCommit;
  final void Function()? afterWrite;
  final void Function()? afterCommit;

  const _FaultingExportFileOperations({
    this.failWrite = false,
    this.failCommit = false,
    this.afterWrite,
    this.afterCommit,
  });

  @override
  Future<File> createStage(File destination) async {
    final stage = File('${destination.path}.attempt-stage');
    await stage.create(exclusive: true);
    return stage;
  }

  @override
  Future<void> writeStage(File stage, Uint8List bytes) async {
    await stage.writeAsBytes(failWrite ? bytes.sublist(0, 2) : bytes,
        flush: true);
    if (failWrite) throw StateError('simulated partial write');
    afterWrite?.call();
  }

  @override
  Future<File> commitStage(File stage, File destination) async {
    if (failCommit) throw StateError('simulated commit failure');
    final file = await stage.rename(destination.path);
    afterCommit?.call();
    return file;
  }

  @override
  Future<void> removeStage(File stage) async {
    if (await stage.exists()) await stage.delete();
  }
}

class _PartialIoStageWrite extends IoExportFileOperations {
  final File destination;
  bool? destinationExistsBeforeCommit;

  _PartialIoStageWrite(this.destination);

  @override
  Future<void> writeStage(File stage, Uint8List bytes) async {
    await stage.writeAsBytes(bytes.sublist(0, 2), flush: true);
    destinationExistsBeforeCommit = await destination.exists();
    throw StateError('simulated partial write');
  }
}

class _PhysicalPixelCaptureService extends ExportService {
  double? capturedPixelRatio;
  final Uint8List? captureBytes;

  _PhysicalPixelCaptureService({super.worker, this.captureBytes});

  @override
  Future<Uint8List> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 2.0,
  }) async {
    capturedPixelRatio = pixelRatio;
    return captureBytes ??
        Uint8List.fromList(
          img.encodePng(img.Image(width: 108, height: 192)),
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const service = ExportService();

  group('ExportAspectCrop.center', () {
    test('center-crops a portrait capture to a square target', () {
      final crop = ExportAspectCrop.center(
        sourceWidth: 1080,
        sourceHeight: 2338,
        targetWidth: 1080,
        targetHeight: 1080,
      );
      expect(crop.width, 1080);
      expect(crop.height, 1080);
      expect(crop.x, 0);
      expect(crop.y, 629); // (2338 - 1080) / 2
    });

    test('crops a portrait capture to a landscape target without stretching',
        () {
      final crop = ExportAspectCrop.center(
        sourceWidth: 1080,
        sourceHeight: 2338,
        targetWidth: 1200,
        targetHeight: 675,
      );
      expect(crop.width, 1080);
      expect(crop.height, 608); // round(1080 / (1200/675))
      // The crop must carry the target aspect, not the source aspect.
      expect((crop.width / crop.height - 1200 / 675).abs(), lessThan(0.01));
      expect(crop.x, 0);
    });

    test('returns the full frame when the aspects already match', () {
      final crop = ExportAspectCrop.center(
        sourceWidth: 1080,
        sourceHeight: 1920,
        targetWidth: 540,
        targetHeight: 960,
      );
      expect(crop.width, 1080);
      expect(crop.height, 1920);
      expect(crop.x, 0);
      expect(crop.y, 0);
    });

    test('stays within the source bounds for extreme aspect ratios', () {
      final crop = ExportAspectCrop.center(
        sourceWidth: 100,
        sourceHeight: 100,
        targetWidth: 1000,
        targetHeight: 1,
      );
      expect(crop.x, greaterThanOrEqualTo(0));
      expect(crop.y, greaterThanOrEqualTo(0));
      expect(crop.x + crop.width, lessThanOrEqualTo(100));
      expect(crop.y + crop.height, lessThanOrEqualTo(100));
      expect(crop.width, greaterThan(0));
      expect(crop.height, greaterThan(0));
    });
  });

  group('ExportService.capturePng', () {
    test('does not call release-unsafe debug paint getters', () {
      final source = File('lib/core/services/export/export_service.dart')
          .readAsStringSync();

      expect(source, isNot(contains('.debugNeedsPaint')));
    });
  });

  group('ExportService.captureWithOptions', () {
    test('worker export preserves highlight brightness and alpha', () async {
      final source = img.Image(width: 2, height: 2, numChannels: 4);
      source.setPixelRgba(0, 0, 255, 255, 255, 255);
      source.setPixelRgba(1, 0, 0, 0, 0, 255);
      source.setPixelRgba(0, 1, 255, 0, 255, 0);
      source.setPixelRgba(1, 1, 0, 255, 0, 0);
      final service = _PhysicalPixelCaptureService(
        captureBytes: Uint8List.fromList(img.encodePng(source)),
      );
      // Uses the real isolate worker, capture processing, and PNG encoder.
      final bytes = await service.captureWithOptions(
        GlobalKey(),
        options: const ExportOptions(
          resolution: ExportResolution.custom,
          customWidth: 1,
          customHeight: 1,
          transparentBackground: true,
        ),
        screenWidth: 2,
        screenHeight: 2,
      );
      final output = img.decodePng(bytes)!;
      expect((output.width, output.height), (1, 1));
      final pixel = output.getPixel(0, 0);
      expect([pixel.r, pixel.g, pixel.b, pixel.a], [188, 188, 188, 128]);
    });

    test('screen mode captures and outputs the physical pixel size', () async {
      final worker = _RecordingExportWorker();
      final service = _PhysicalPixelCaptureService(worker: worker);

      final bytes = await service.captureWithOptions(
        GlobalKey(),
        options: const ExportOptions(resolution: ExportResolution.screen),
        screenWidth: 108 / 2.625,
        screenHeight: 192 / 2.625,
        physicalScreenWidth: 108,
        physicalScreenHeight: 192,
      );
      final decoded = img.decodePng(bytes)!;

      expect(service.capturedPixelRatio, closeTo(2.625, 0.0001));
      expect((decoded.width, decoded.height), (108, 192));
      expect(worker.calls, 1);
    });
  });

  group('ExportService.resizePngToTargetDimensions', () {
    test('fallback worker retains color-correct output', () async {
      final source = img.Image(width: 2, height: 2);
      source.setPixelRgb(0, 0, 255, 255, 255);
      source.setPixelRgb(1, 1, 255, 255, 255);
      final output = img.decodePng(await service.resizePngInWorker(
        Uint8List.fromList(img.encodePng(source)),
        width: 1,
        height: 1,
      ))!;
      expect(output.getPixel(0, 0).r, 188);
    });

    test('fallback worker respects cancellation before processing', () async {
      final token = ExportCancellationToken()..cancel();
      await expectLater(
        service.resizePngInWorker(
          Uint8List(0),
          width: 1,
          height: 1,
          cancellationToken: token,
        ),
        throwsA(isA<ExportCancelledException>()),
      );
    });

    test('preserves fine-detail brightness when shrinking artwork', () {
      final source = img.Image(width: 2, height: 2);
      source.setPixelRgb(0, 0, 255, 255, 255);
      source.setPixelRgb(1, 1, 255, 255, 255);
      final output = img.decodePng(service.resizePngToTargetDimensions(
        Uint8List.fromList(img.encodePng(source)),
        width: 1,
        height: 1,
      ))!;

      final pixel = output.getPixel(0, 0);
      expect(pixel.r, closeTo(188, 1));
      expect(pixel.g, closeTo(188, 1));
      expect(pixel.b, closeTo(188, 1));
    });

    test('resizes fallback exports to the requested high-res target', () {
      final source = img.Image(width: 40, height: 20);
      img.fill(source, color: img.ColorRgb8(12, 34, 56));
      final bytes = Uint8List.fromList(img.encodePng(source));

      final resized = service.resizePngToTargetDimensions(
        bytes,
        width: 120,
        height: 90,
      );
      final decoded = img.decodePng(resized);

      expect(decoded, isNotNull);
      expect(decoded!.width, 120);
      expect(decoded.height, 90);
    });

    test('rejects invalid captured PNG bytes', () {
      expect(
        () => service.resizePngToTargetDimensions(
          Uint8List.fromList([1, 2, 3]),
          width: 120,
          height: 90,
        ),
        throwsStateError,
      );
    });
  });

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

    test('sanitizes prefix and fractal type before building file path names',
        () {
      const parts = ExportFilenameParts(
        prefix: ' ../My Export// ',
        fractalType: ' Burning Ship/../../Secrets ',
        timestampMillis: 1234,
        format: ExportFormat.png,
      );

      expect(parts.safePrefix, 'my_export');
      expect(parts.safeFractalType, 'burning_ship_secrets');
      expect(parts.filename, 'my_export_burning_ship_secrets_1234.png');
      expect(parts.filename, isNot(contains('/')));
      expect(parts.filename, isNot(startsWith('.')));
    });

    test('falls back when prefix has no safe filename characters', () {
      const parts = ExportFilenameParts(
        prefix: '../..',
        timestampMillis: 1234,
        format: ExportFormat.jpg,
      );

      expect(parts.safePrefix, 'fractal');
      expect(parts.filename, 'fractal_1234.jpg');
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

  group('ExportService watermark', () {
    test('clamps watermark coordinates inside image bounds', () {
      final source = File('lib/core/services/export/export_service.dart')
          .readAsStringSync();
      final method =
          source.substring(source.indexOf('img.Image _addWatermark'));

      expect(method, contains('.clamp(0, image.width - 1)'));
      expect(method, contains('.clamp(0, image.height - 1)'));
    });
  });

  group('ExportService quote overlay', () {
    test('inverts only glyph pixels over the fractal image', () {
      final image = img.Image(width: 300, height: 120);
      img.fill(image, color: img.ColorRgb8(10, 20, 30));

      final result = service.applyInvertedTextOverlay(image, 'Hi');

      var inverted = 0;
      var untouched = 0;
      for (var y = 0; y < result.height; y++) {
        for (var x = 0; x < result.width; x++) {
          final p = result.getPixel(x, y);
          if (p.r == 245 && p.g == 235 && p.b == 225) {
            inverted++;
          }
          if (p.r == 10 && p.g == 20 && p.b == 30) {
            untouched++;
          }
        }
      }

      expect(inverted, greaterThan(0));
      expect(untouched, greaterThan(0));
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

    test('homeOptimized darkens the bottom edge on small images', () {
      final result =
          service.applyWallpaperStyle(testPng, style: 'homeOptimized');
      final decoded = img.decodePng(result)!;

      final top = decoded.getPixel(0, 0);
      final bottom = decoded.getPixel(0, decoded.height - 1);

      expect(top.r.toInt(), 200);
      expect(top.g.toInt(), 50);
      expect(top.b.toInt(), 50);
      expect(bottom.r.toInt(), lessThan(top.r.toInt()));
      expect(bottom.g.toInt(), lessThan(top.g.toInt()));
      expect(bottom.b.toInt(), lessThan(top.b.toInt()));
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
      expect(opts.calculatePixelRatio(400, 300), 1.0);
    });

    test('getTargetDimensions returns preset dimensions', () {
      const opts = ExportOptions(resolution: ExportResolution.fullHd);
      expect(opts.getTargetDimensions(400, 300), (1920, 1080));
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

  group('ExportSizePolicy', () {
    test('allows 4K preset pixel counts', () {
      expect(
        () => ExportSizePolicy.validateTargetDimensions(3840, 2160),
        returnsNormally,
      );
    });

    test('rejects oversized custom dimensions before capture', () {
      expect(
        () => ExportSizePolicy.validateTargetDimensions(20000, 20000),
        throwsStateError,
      );
    });

    test('rejects oversized encoded payloads before save/share', () {
      expect(
        () => ExportSizePolicy.validateEncodedByteLength(
          ExportSizePolicy.maxEncodedImageBytes + 1,
        ),
        throwsStateError,
      );
    });
  });

  group('ExportService.shareFile', () {
    test('uses injected file share adapter', () async {
      File? sharedFile;
      String? sharedText;
      final service = ExportService(
        shareFile: (file, {text}) async {
          sharedFile = file;
          sharedText = text;
        },
      );
      final file = File('/tmp/fractal.png');

      await service.shareFile(file, text: 'Fractal Forge');

      expect(sharedFile, file);
      expect(sharedText, 'Fractal Forge');
    });

    test('uses AppShareService file adapter by default', () {
      expect(const ExportService().shareFileAdapter, isA<ShareFileCallback>());
    });
  });

  group('ExportService native export commits', () {
    test('partial stage write preserves existing destination', () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_commit_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')
        ..createSync(recursive: true);
      final destination = File('${directory.path}/sample.png')
        ..writeAsStringSync('existing output');
      final service = ExportService(
        fileOperations: const _FaultingExportFileOperations(failWrite: true),
      );

      await expectLater(
        service.saveBytes(Uint8List.fromList([1, 2, 3, 4]),
            filename: 'sample.png'),
        throwsA(isA<StateError>()),
      );

      expect(await destination.readAsString(), 'existing output');
      expect(await File('${destination.path}.attempt-stage').exists(), isFalse);
    });

    test('commit failure preserves collision and retry replaces it safely',
        () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_retry_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')
        ..createSync(recursive: true);
      final destination = File('${directory.path}/sample.png')
        ..writeAsStringSync('old bytes');
      final abandoned = File('${destination.path}.stage-unrelated')
        ..writeAsStringSync('untouched');
      final bytes = Uint8List.fromList(
        img.encodePng(img.Image(width: 2, height: 2)),
      );

      await expectLater(
        ExportService(
          fileOperations: const _FaultingExportFileOperations(failCommit: true),
        ).saveBytes(bytes, filename: 'sample.png'),
        throwsA(isA<StateError>()),
      );
      expect(await destination.readAsString(), 'old bytes');
      expect(await File('${destination.path}.attempt-stage').exists(), isFalse);

      final retry = await const ExportService().saveBytes(
        bytes,
        filename: 'sample.png',
      );
      expect(img.decodePng(await retry.readAsBytes()), isNotNull);
      expect(await abandoned.readAsString(), 'untouched');
    });

    test('unsupported directory-link collision fails without unlinking it',
        () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_link_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')..createSync();
      final target = Directory('${root.path}/target')..createSync();
      final marker = File('${target.path}/keep')
        ..writeAsStringSync('untouched');
      final collision = Link('${directory.path}/sample.png');
      await collision.create(target.path);

      await expectLater(
        const ExportService()
            .saveBytes(Uint8List.fromList([1, 2, 3]), filename: 'sample.png'),
        throwsA(isA<FileSystemException>()),
      );

      expect(await collision.target(), target.path);
      expect(await marker.readAsString(), 'untouched');
      expect(await directory.list(followLinks: false).length, 1);
    });

    test('staging preserves a filesystem-valid maximum-length filename',
        () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_long_name_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')..createSync();
      final filename = '${List.filled(251, 'a').join()}.png';
      final destination = File('${directory.path}/$filename');
      // Establish that the destination name itself is supported by this FS.
      await destination.writeAsString('prior image');
      final bytes = Uint8List.fromList(
        img.encodePng(img.Image(width: 2, height: 2)),
      );

      final saved = await const ExportService().saveBytes(
        bytes,
        filename: filename,
      );

      expect(saved.path, destination.path);
      expect(await saved.readAsBytes(), bytes);
      expect(await directory.list().length, 1);
    });

    test('staging-name destination is never published by a failed write',
        () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_stage_name_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')..createSync();
      for (final upperCase in [false, true]) {
        final probe = await const IoExportFileOperations()
            .createStage(File('${directory.path}/probe.png'));
        final next = int.parse(probe.path.split('-').last) + 1;
        await probe.delete();
        final name = '.fractal-export-stage-$pid-$next';
        final filename = upperCase ? name.toUpperCase() : name;
        final destination = File('${directory.path}/$filename');
        final operations = _PartialIoStageWrite(destination);

        await expectLater(
          ExportService(fileOperations: operations).saveBytes(
            Uint8List.fromList([1, 2, 3, 4]),
            filename: filename,
          ),
          throwsA(isA<StateError>()),
        );

        expect(operations.destinationExistsBeforeCommit, isFalse);
        expect(await destination.exists(), isFalse);
        expect(await directory.list().length, 0);
      }
    });

    test('production stage collisions survive a recreated service and retry',
        () async {
      SharedPreferences.setMockInitialValues({});
      final root =
          await Directory.systemTemp.createTemp('export_stage_collision_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')..createSync();
      final destination = File('${directory.path}/sample.png');
      final abandoned =
          await const IoExportFileOperations().createStage(destination);
      await abandoned.writeAsString('abandoned');
      final sequence = int.parse(abandoned.path.split('-').last);
      final occupied =
          File('${directory.path}/.fractal-export-stage-$pid-${sequence + 1}')
            ..writeAsStringSync('occupied');
      final bytes =
          Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));

      final file =
          await const ExportService().saveBytes(bytes, filename: 'sample.png');

      expect(await file.readAsBytes(), bytes);
      expect(img.decodePng(await file.readAsBytes()), isNotNull);
      expect(await abandoned.readAsString(), 'abandoned');
      expect(await occupied.readAsString(), 'occupied');
      expect(await directory.list().length, 3);
    });

    test('cancellation before commit leaves destination unchanged', () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_cancel_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final directory = Directory('${root.path}/exports')
        ..createSync(recursive: true);
      final destination = File('${directory.path}/sample.png')
        ..writeAsStringSync('old bytes');
      final token = ExportCancellationToken();
      final service = ExportService(
        fileOperations: _FaultingExportFileOperations(afterWrite: token.cancel),
      );

      await expectLater(
        service.saveBytesCancellable(
          Uint8List.fromList([1, 2, 3]),
          filename: 'sample.png',
          cancellationToken: token,
        ),
        throwsA(isA<ExportCancelledException>()),
      );
      expect(await destination.readAsString(), 'old bytes');
      expect(await File('${destination.path}.attempt-stage').exists(), isFalse);
    });

    test('cancellation after rename reports the committed image', () async {
      SharedPreferences.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp('export_committed_');
      addTearDown(() => root.delete(recursive: true));
      PathProviderPlatform.instance = _FakePathProviderPlatform(root.path);
      final token = ExportCancellationToken();
      final service = ExportService(
        fileOperations:
            _FaultingExportFileOperations(afterCommit: token.cancel),
      );
      final bytes = Uint8List.fromList(
        img.encodePng(img.Image(width: 2, height: 2)),
      );

      final file = await service.saveBytesCancellable(
        bytes,
        filename: 'sample.png',
        cancellationToken: token,
      );

      expect(token.isCancelled, isTrue);
      expect(img.decodePng(await file.readAsBytes()), isNotNull);
    });
  });

  group('ExportService.getExportDirectory', () {
    late Directory tmpDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tmpDir = await Directory.systemTemp.createTemp('export_test_');
      PathProviderPlatform.instance = _FakePathProviderPlatform(tmpDir.path);
    });

    tearDown(() async {
      if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
    });

    test('returns a valid directory that exists', () async {
      final dir = await service.getExportDirectory();
      expect(await dir.exists(), isTrue);
    });

    test('returned directory path is non-empty', () async {
      final dir = await service.getExportDirectory();
      expect(dir.path, isNotEmpty);
    });

    test('uses saved Linux export directory preference', () async {
      final chosen = Directory('${tmpDir.path}/chosen');
      await service.setPreferredExportDirectory(chosen);

      final dir = await service.getExportDirectory();

      expect(dir.path, chosen.path);
      expect(await dir.exists(), isTrue);
    });

    test('Linux directory picker saves preference', () async {
      final chosen = Directory('${tmpDir.path}/picked');
      String? seenInitialDirectory;
      final pickingService = ExportService(
        pickDirectory: ({confirmButtonText, initialDirectory}) async {
          seenInitialDirectory = initialDirectory;
          return chosen.path;
        },
      );

      final ok = await pickingService.chooseLinuxExportDirectory();
      final dir = await pickingService.getExportDirectory();

      expect(ok, isTrue);
      expect(seenInitialDirectory, '${tmpDir.path}/exports');
      expect(dir.path, chosen.path);
    });

    test('reuses the saved Linux directory without reopening the picker',
        () async {
      final chosen = Directory('${tmpDir.path}/chosen');
      await service.setPreferredExportDirectory(chosen);
      var pickerCalls = 0;
      final pickingService = ExportService(
        pickDirectory: ({confirmButtonText, initialDirectory}) async {
          pickerCalls++;
          return null;
        },
      );

      final ok = await pickingService.chooseLinuxExportDirectory();

      expect(ok, isTrue);
      expect(pickerCalls, 0);
      expect((await pickingService.getExportDirectory()).path, chosen.path);
    });
  });

  group('ExportService image encoding', () {
    // These tests exercise the encode logic that _encodeToFormat uses
    // by building an img.Image and encoding it with the same calls the
    // service makes, verifying the output bytes are valid image data.

    late img.Image testImage;

    setUp(() {
      testImage = img.Image(width: 8, height: 8);
      img.fill(testImage, color: img.ColorRgb8(100, 150, 200));
    });

    test('PNG encoding produces valid PNG bytes', () {
      final bytes = Uint8List.fromList(img.encodePng(testImage, level: 6));
      expect(bytes.length, greaterThan(8));
      // PNG magic bytes: 0x89 'P' 'N' 'G'
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50); // 'P'
      expect(bytes[2], 0x4E); // 'N'
      expect(bytes[3], 0x47); // 'G'
      final decoded = img.decodePng(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 8);
      expect(decoded.height, 8);
    });

    test('JPG encoding produces valid JPEG bytes', () {
      final rgbImage = img.Image(width: 8, height: 8, numChannels: 3);
      img.fill(rgbImage, color: img.ColorRgb8(100, 150, 200));
      img.compositeImage(rgbImage, testImage);
      final bytes = Uint8List.fromList(img.encodeJpg(rgbImage, quality: 85));
      expect(bytes.length, greaterThan(2));
      // JPEG SOI marker: 0xFF 0xD8
      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
      final decoded = img.decodeJpg(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 8);
      expect(decoded.height, 8);
    });

    test('WebP requested format resolves to PNG (no native WebP encoder)', () {
      // The service documents that WebP falls back to PNG encoding.
      final effective = service.resolveEffectiveFormat(ExportFormat.webp);
      expect(effective, ExportFormat.png);
      // The resulting bytes are valid PNG.
      final bytes = Uint8List.fromList(img.encodePng(testImage));
      expect(bytes[0], 0x89);
      expect(bytes[1], 0x50);
    });

    test('export encoding fails gracefully on null decode returns original',
        () {
      // applyWallpaperStyle returns original bytes when PNG decode fails.
      final garbage = Uint8List.fromList([0, 1, 2, 3]);
      final result =
          service.applyWallpaperStyle(garbage, style: 'homeOptimized');
      expect(result, same(garbage));
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
