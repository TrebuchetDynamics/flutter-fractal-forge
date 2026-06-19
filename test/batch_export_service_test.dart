// Tests for BatchExportService.
//
// Key constraint: exportPresets() calls WidgetsBinding.instance.endOfFrame
// for every preset that enters the loop body. That future only resolves when
// the Flutter test framework pumps a frame, which doesn't happen inside
// testWidgets/tester.runAsync reliably.
//
// Strategy:
//   - All exportPresets tests use plain test() with isCancelled:()=>true so
//     the loop guard fires before the body (and before endOfFrame is awaited).
//   - The empty-presets path also never reaches endOfFrame.
//   - Value-type tests (BatchExportItemResult, BatchExportResult, ExportOptions)
//     are pure synchronous tests.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/batch_export_service.dart';
import 'package:flutter_fractals/core/services/export_service.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart';

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

/// Stub [ExportService] that resolves directory ops without platform channels.
/// captureWithOptions throws to make it obvious if a test accidentally reaches
/// the loop body.
class _StubExportService extends ExportService {
  final String basePath;

  const _StubExportService(this.basePath);

  @override
  Future<Directory> getExportDirectory() async {
    final dir = Directory('$basePath/exports');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<Uint8List> captureWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    void Function(double)? onProgress,
  }) async {
    throw UnimplementedError(
        'captureWithOptions should not be reached in these tests');
  }
}

class _FixedBatchExportClock implements BatchExportClock {
  final DateTime value;

  const _FixedBatchExportClock(this.value);

  @override
  DateTime now() => value;
}

class _NoopBatchExportFramePump implements BatchExportFramePump {
  const _NoopBatchExportFramePump();

  @override
  Future<void> waitForPresetRender() async {}
}

class _CapturingExportService extends _StubExportService {
  final capturedOptions = <ExportOptions>[];

  _CapturingExportService(super.basePath);

  @override
  Future<Uint8List> captureWithOptions(
    GlobalKey boundaryKey, {
    required ExportOptions options,
    required double screenWidth,
    required double screenHeight,
    void Function(double)? onProgress,
  }) async {
    capturedOptions.add(options);
    final image = img.Image(width: 1, height: 1);
    img.fill(image, color: img.ColorRgb8(1, 2, 3));
    return Uint8List.fromList(img.encodePng(image));
  }
}

FractalPreset _makePreset(String name) => FractalPreset(
      id: name,
      moduleId: 'mandelbrot',
      name: name,
      params: const {},
      view: FractalViewState(
        pan: Vector2.zero(),
        zoom: 1.0,
        rotation: Vector3.zero(),
      ),
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmpDir;
  late _StubExportService stubService;
  late BatchExportService service;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('batch_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tmpDir.path);
    stubService = _StubExportService(tmpDir.path);
    service = BatchExportService(exportService: stubService);
  });

  tearDown(() async {
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
  });

  Future<BatchExportResult> runBatchExport({
    BatchExportService? usingService,
    Future<void> Function(FractalPreset preset)? applyPreset,
    List<FractalPreset> presets = const [],
    String moduleId = 'mandelbrot',
    String moduleDisplayName = 'Mandelbrot',
    void Function(double overallProgress, String status)? onProgress,
    void Function(BatchExportItemResult item)? onItemDone,
    bool Function()? isCancelled,
  }) {
    return (usingService ?? service).exportPresets(
      boundaryKey: GlobalKey(),
      applyPreset: applyPreset ?? (_) async {},
      presets: presets,
      options: const ExportOptions(format: ExportFormat.png),
      screenWidth: 400,
      screenHeight: 800,
      moduleId: moduleId,
      moduleDisplayName: moduleDisplayName,
      currentParameters: () => {},
      onProgress: onProgress,
      onItemDone: onItemDone,
      isCancelled: isCancelled ?? () => false,
    );
  }

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------
  group('BatchExportService construction', () {
    test('can be created with default ExportService', () {
      const svc = BatchExportService();
      expect(svc, isNotNull);
    });

    test('can be created with custom ExportService', () {
      expect(service, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Value types — pure synchronous
  // ---------------------------------------------------------------------------
  group('BatchExportItemResult', () {
    test('holds preset, file, and index correctly', () {
      final preset = _makePreset('My Preset');
      final file = File('/tmp/test.png');
      final item = BatchExportItemResult(preset: preset, file: file, index: 3);
      expect(item.preset.name, 'My Preset');
      expect(item.file.path, '/tmp/test.png');
      expect(item.index, 3);
    });

    test('index zero is valid', () {
      final item = BatchExportItemResult(
        preset: _makePreset('First'),
        file: File('/tmp/first.png'),
        index: 0,
      );
      expect(item.index, 0);
    });

    test('preset fields are accessible via item', () {
      final preset = _makePreset('Deep Zoom');
      final item = BatchExportItemResult(
        preset: preset,
        file: File('/tmp/deep.png'),
        index: 5,
      );
      expect(item.preset.id, 'Deep Zoom');
      expect(item.preset.moduleId, 'mandelbrot');
    });
  });

  group('BatchExportPlan', () {
    test('filters presets to the requested module before export', () {
      final plan = BatchExportPlan.forModule(
        moduleId: 'mandelbrot',
        presets: [
          _makePreset('Mandelbrot A'),
          _makePreset('Julia A').copyWith(moduleId: 'julia'),
          _makePreset('Mandelbrot B'),
        ],
      );

      expect(plan.entries.map((e) => e.preset.name), [
        'Mandelbrot A',
        'Mandelbrot B',
      ]);
      expect(plan.entries.map((e) => e.sourceIndex), [0, 2]);
      expect(plan.entries.map((e) => e.exportIndex), [0, 1]);
      expect(plan.total, 2);
    });
  });

  group('BatchExportCompletion', () {
    test('reports successful runs as done regardless of item count', () {
      const completion = BatchExportCompletion(
        completedItems: 0,
        plannedItems: 0,
        wasCancelled: false,
      );

      expect(completion.progress, 1.0);
      expect(completion.status, 'Done');
    });

    test('reports cancelled runs with bounded partial progress', () {
      const completion = BatchExportCompletion(
        completedItems: 1,
        plannedItems: 3,
        wasCancelled: true,
      );
      const overrunCompletion = BatchExportCompletion(
        completedItems: 4,
        plannedItems: 3,
        wasCancelled: true,
      );

      expect(completion.progress, closeTo(1 / 3, 1e-12));
      expect(completion.status, 'Cancelled after 1/3');
      expect(overrunCompletion.progress, 1.0);
      expect(overrunCompletion.status, 'Cancelled after 3/3');
    });
  });

  group('BatchExportResult', () {
    test('holds directory, items, and no contact sheet', () {
      final dir = Directory('/tmp/batch');
      final file = File('/tmp/batch/file.png');
      final item =
          BatchExportItemResult(preset: _makePreset('P'), file: file, index: 0);
      final result =
          BatchExportResult(directory: dir, items: [item], contactSheet: null);
      expect(result.directory.path, '/tmp/batch');
      expect(result.items, hasLength(1));
      expect(result.contactSheet, isNull);
    });

    test('contact sheet field can be populated', () {
      final result = BatchExportResult(
        directory: Directory('/tmp/batch'),
        items: const [],
        contactSheet: File('/tmp/batch/contact_sheet_mandelbrot.png'),
      );
      expect(result.contactSheet, isNotNull);
      expect(result.contactSheet!.path, endsWith('.png'));
    });

    test('empty items list is valid', () {
      final result = BatchExportResult(
        directory: Directory('/tmp/batch'),
        items: const [],
        contactSheet: null,
      );
      expect(result.items, isEmpty);
    });

    test('multiple items can be stored', () {
      final items = List.generate(
        5,
        (i) => BatchExportItemResult(
          preset: _makePreset('P$i'),
          file: File('/tmp/p$i.png'),
          index: i,
        ),
      );
      final result = BatchExportResult(
        directory: Directory('/tmp/batch'),
        items: items,
        contactSheet: null,
      );
      expect(result.items, hasLength(5));
      expect(result.items[2].index, 2);
      expect(result.items[4].preset.name, 'P4');
    });
  });

  // ---------------------------------------------------------------------------
  // exportPresets — cancellation before loop body
  // Uses plain test() so real async IO works without fake-async interference.
  // isCancelled always returns true so endOfFrame is never awaited.
  // ---------------------------------------------------------------------------
  group('BatchExportService.exportPresets cancellation before loop body', () {
    test('empty preset list returns empty result without reaching loop body',
        () async {
      final result = await runBatchExport();

      expect(result.items, isEmpty);
      expect(result.contactSheet, isNull);
    });

    test('empty preset list: only final 1.0 progress call is made', () async {
      final progressValues = <double>[];

      await runBatchExport(onProgress: (p, _) => progressValues.add(p));

      expect(progressValues, equals([1.0]));
    });

    test('isCancelled=true: applyPreset is never called', () async {
      bool applyWasCalled = false;

      await runBatchExport(
        applyPreset: (_) async => applyWasCalled = true,
        presets: [_makePreset('Alpha')],
        isCancelled: () => true,
      );

      expect(applyWasCalled, isFalse);
    });

    test('isCancelled=true: result has empty items and no contact sheet',
        () async {
      final result = await runBatchExport(
        presets: [_makePreset('Alpha'), _makePreset('Beta')],
        isCancelled: () => true,
      );

      expect(result.items, isEmpty);
      expect(result.contactSheet, isNull);
    });

    test('isCancelled=true with many presets: none are applied', () async {
      int applyCount = 0;

      await runBatchExport(
        applyPreset: (_) async => applyCount++,
        presets: [_makePreset('A'), _makePreset('B'), _makePreset('C')],
        isCancelled: () => true,
      );

      expect(applyCount, 0);
    });

    test('isCancelled=true: onItemDone is never called', () async {
      int doneCalls = 0;

      await runBatchExport(
        presets: [_makePreset('X'), _makePreset('Y')],
        onItemDone: (_) => doneCalls++,
        isCancelled: () => true,
      );

      expect(doneCalls, 0);
    });

    test('result directory exists after empty export', () async {
      final result = await runBatchExport();

      expect(await result.directory.exists(), isTrue);
    });

    test('batch directory name contains slugified moduleId', () async {
      final result = await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: const [],
        options: const ExportOptions(format: ExportFormat.png),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'Mandelbrot Set',
        moduleDisplayName: 'Mandelbrot Set',
        currentParameters: () => {},
        onProgress: null,
        onItemDone: null,
        isCancelled: () => false,
      );

      final dirName =
          result.directory.uri.pathSegments.where((s) => s.isNotEmpty).last;
      expect(dirName, contains('mandelbrot_set'));
    });

    test('batch directory name starts with "batch_"', () async {
      final result = await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: const [],
        options: const ExportOptions(format: ExportFormat.png),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'julia',
        moduleDisplayName: 'Julia Set',
        currentParameters: () => {},
        onProgress: null,
        onItemDone: null,
        isCancelled: () => false,
      );

      final dirName =
          result.directory.uri.pathSegments.where((s) => s.isNotEmpty).last;
      expect(dirName, startsWith('batch_'));
    });

    test('repeated exports in the same second get unique directories',
        () async {
      final fixedClock =
          _FixedBatchExportClock(DateTime(2026, 6, 1, 12, 34, 56));
      final deterministicService = BatchExportService(
        exportService: stubService,
        clock: fixedClock,
      );

      Future<BatchExportResult> runEmptyExport() {
        return deterministicService.exportPresets(
          boundaryKey: GlobalKey(),
          applyPreset: (_) async {},
          presets: const [],
          options: const ExportOptions(format: ExportFormat.png),
          screenWidth: 400,
          screenHeight: 800,
          moduleId: 'mandelbrot',
          moduleDisplayName: 'Mandelbrot',
          currentParameters: () => {},
          onProgress: null,
          onItemDone: null,
          isCancelled: () => false,
        );
      }

      final first = await runEmptyExport();
      final second = await runEmptyExport();

      expect(second.directory.path, isNot(first.directory.path));
      expect(second.directory.path, endsWith('_02'));
      expect(await first.directory.exists(), isTrue);
      expect(await second.directory.exists(), isTrue);
    });

    test('mixed-module presets are skipped before apply/export', () async {
      final capturingService = _CapturingExportService(tmpDir.path);
      final service = BatchExportService(
        exportService: capturingService,
        framePump: const _NoopBatchExportFramePump(),
      );
      final applied = <String>[];
      final done = <BatchExportItemResult>[];

      final result = await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (preset) async => applied.add(preset.name),
        presets: [
          _makePreset('Mandelbrot A'),
          _makePreset('Julia A').copyWith(moduleId: 'julia'),
          _makePreset('Mandelbrot B'),
        ],
        options: const ExportOptions(format: ExportFormat.png),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'mandelbrot',
        moduleDisplayName: 'Mandelbrot',
        currentParameters: () => {},
        onProgress: null,
        onItemDone: done.add,
        isCancelled: () => false,
      );

      expect(applied, ['Mandelbrot A', 'Mandelbrot B']);
      expect(capturingService.capturedOptions, hasLength(2));
      expect(done.map((item) => item.index), [0, 1]);
      expect(result.items.map((item) => item.preset.name), [
        'Mandelbrot A',
        'Mandelbrot B',
      ]);
      expect(
        result.items.map((item) => item.file.path),
        everyElement(contains('mandelbrot')),
      );
    });

    test('batch metadata uses the injected clock for replayable timestamps',
        () async {
      final fixedTime = DateTime(2026, 6, 1, 12, 34, 56);
      final capturingService = _CapturingExportService(tmpDir.path);
      final service = BatchExportService(
        exportService: capturingService,
        clock: _FixedBatchExportClock(fixedTime),
        framePump: const _NoopBatchExportFramePump(),
      );

      await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: [_makePreset('Meta')],
        options: const ExportOptions(embedMetadata: true),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'mandelbrot',
        moduleDisplayName: 'Mandelbrot',
        currentParameters: () => {'iterations': 100},
        onProgress: null,
        onItemDone: null,
        isCancelled: () => false,
      );

      expect(capturingService.capturedOptions, hasLength(1));
      expect(capturingService.capturedOptions.single.metadata?.createdAt,
          fixedTime);
    });

    test('batch WebP fallback uses truthful PNG capture options and filenames',
        () async {
      final capturingService = _CapturingExportService(tmpDir.path);
      final service = BatchExportService(
        exportService: capturingService,
        framePump: const _NoopBatchExportFramePump(),
      );

      final result = await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: [_makePreset('WebP Fallback')],
        options: const ExportOptions(
          format: ExportFormat.webp,
          embedMetadata: false,
        ),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'mandelbrot',
        moduleDisplayName: 'Mandelbrot',
        currentParameters: () => {},
        onProgress: null,
        onItemDone: null,
        isCancelled: () => false,
      );

      expect(capturingService.capturedOptions.single.format, ExportFormat.png);
      expect(result.items.single.file.path, endsWith('.png'));
      expect(result.items.single.file.path, isNot(endsWith('.webp')));
    });

    test('mid-export cancellation reports partial progress instead of done',
        () async {
      final capturingService = _CapturingExportService(tmpDir.path);
      final service = BatchExportService(
        exportService: capturingService,
        framePump: const _NoopBatchExportFramePump(),
      );
      final progress = <({double value, String status})>[];
      var cancelChecks = 0;

      final result = await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: [
          _makePreset('First'),
          _makePreset('Second'),
          _makePreset('Third'),
        ],
        options: const ExportOptions(format: ExportFormat.png),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'mandelbrot',
        moduleDisplayName: 'Mandelbrot',
        currentParameters: () => {},
        onProgress: (value, status) => progress.add((
          value: value,
          status: status,
        )),
        onItemDone: null,
        isCancelled: () => cancelChecks++ > 0,
      );

      expect(result.items, hasLength(1));
      expect(result.contactSheet, isNull);
      expect(progress.last.value, closeTo(1 / 3, 1e-12));
      expect(progress.last.status, 'Cancelled after 1/3');
    });

    test('currentParameters is not called when isCancelled=true', () async {
      int paramCalls = 0;

      await service.exportPresets(
        boundaryKey: GlobalKey(),
        applyPreset: (_) async {},
        presets: [_makePreset('Meta')],
        options: const ExportOptions(embedMetadata: true),
        screenWidth: 400,
        screenHeight: 800,
        moduleId: 'mandelbrot',
        moduleDisplayName: 'Mandelbrot',
        currentParameters: () {
          paramCalls++;
          return {'iterations': 100};
        },
        onProgress: null,
        onItemDone: null,
        isCancelled: () => true,
      );

      expect(paramCalls, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // ExportOptions model — pure synchronous unit tests
  // ---------------------------------------------------------------------------
  group('ExportOptions used in batch configuration', () {
    test('PNG format has correct extension', () {
      const opts = ExportOptions(format: ExportFormat.png);
      expect(opts.format.extension, 'png');
    });

    test('JPG format has correct extension', () {
      const opts = ExportOptions(format: ExportFormat.jpg);
      expect(opts.format.extension, 'jpg');
    });

    test('embedMetadata defaults to true', () {
      const opts = ExportOptions();
      expect(opts.embedMetadata, isTrue);
    });

    test('copyWith preserves unspecified fields', () {
      const original = ExportOptions(
        format: ExportFormat.png,
        quality: 90,
        embedMetadata: false,
      );
      final copied = original.copyWith(format: ExportFormat.jpg);
      expect(copied.format, ExportFormat.jpg);
      expect(copied.quality, 90);
      expect(copied.embedMetadata, isFalse);
    });

    test('getTargetDimensions returns fullHd dimensions', () {
      const opts = ExportOptions(resolution: ExportResolution.fullHd);
      expect(opts.getTargetDimensions(400, 300), (1920, 1080));
    });

    test('calculatePixelRatio clamps to 8.0 maximum', () {
      const opts = ExportOptions(resolution: ExportResolution.uhd4k);
      expect(opts.calculatePixelRatio(100, 100), 8.0);
    });

    test('ExportFormat.webp has webp extension', () {
      expect(ExportFormat.webp.extension, 'webp');
    });

    test('ExportResolution.instagram returns square dimensions', () {
      const opts = ExportOptions(resolution: ExportResolution.instagram);
      final dims = opts.getTargetDimensions(400, 400);
      expect(dims.$1, dims.$2); // square
    });
  });
}
