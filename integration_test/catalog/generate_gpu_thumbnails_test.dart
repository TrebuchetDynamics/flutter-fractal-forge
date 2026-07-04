/// Generates GPU-rendered catalog thumbnails.
///
/// Stages output by default so catalog-wide runs do not accidentally churn
/// tracked assets. Use UPDATE_CATALOG_THUMBS=true to write to
/// assets/catalog_thumbs/.
///
/// Run a small smoke pass:
///   CATALOG_THUMB_LIMIT=5 flutter test integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux
///
/// Useful environment controls:
///   CATALOG_THUMB_SEED=20260616
///   CATALOG_THUMB_LIMIT=20
///   CATALOG_THUMB_OFFSET=0
///   CATALOG_THUMB_ONLY=mandelbrot,julia,core.phoenix
///   UPDATE_CATALOG_THUMBS=true
///   STRICT_CATALOG_THUMBS=true
///
/// Marketing capture (high-res stills of the featured launch set):
///   LAUNCH_MEDIA_SIZE=1080 flutter test \
///     integration_test/catalog/generate_gpu_thumbnails_test.dart -d linux
///   # Renders kFeaturedLaunchSetModuleIds at 1080x1080 into
///   # build/test_output/launch_media/. Combine with CATALOG_THUMB_ONLY to
///   # capture a specific module, or CATALOG_THUMB_SEED to vary color schemes.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_entry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_fractals/features/catalog/data/featured_launch_set.dart';
import 'package:flutter_fractals/features/catalog/data/launch_visual_metrics.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

const int _catalogAssetThumbSize = 320;
const int _stagedSmokeThumbSize = 256;
const int _minimumPngBytes = 500;
const int _minimumUniqueRgbColors = 16;
const double _minimumLuminanceStdDev = 3.0;
const double _minimumNonTransparentPixelRatio = 0.05;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate GPU thumbnails', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });
    await PaletteService.create();

    final env = Platform.environment;
    final updateAssets = _envBool(env, 'UPDATE_CATALOG_THUMBS');
    final strict = _envBool(env, 'STRICT_CATALOG_THUMBS');
    final seed = env['CATALOG_THUMB_SEED'] ?? 'catalog-thumbnails-v1';
    // LAUNCH_MEDIA_SIZE=<px> switches this run into marketing mode: render the
    // curated featured launch set at a high (square) resolution into a separate
    // launch_media output directory, instead of catalog thumbnails.
    final launchMediaSize = _envInt(env, 'LAUNCH_MEDIA_SIZE');
    final launchMedia = launchMediaSize != null;
    final thumbSize = launchMediaSize ??
        (updateAssets ? _catalogAssetThumbSize : _stagedSmokeThumbSize);
    final registry = ModuleRegistry();
    final entries = _selectEntries(
      CatalogRepository.fromRegistry(registry)
          .entries
          .where((entry) => !_isDiagnosticModule(entry.module))
          .toList(growable: false),
      env,
      defaultToFeatured: launchMedia,
    );

    final report = <String, Object>{
      'seed': seed,
      'updateAssets': updateAssets,
      'strict': strict,
      'thumbnailSize': thumbSize,
      'thumbnailStandard': launchMedia
          ? 'launch-media'
          : (updateAssets ? 'catalog-assets' : 'staged-smoke'),
      'performanceNotes': <String>[
        'shaderLoadMs measures ui.FragmentProgram.fromAsset in this process; repeated shader assets may benefit from Flutter asset/shader cache.',
        'renderWarmupMs measures widget build plus three 500ms pumps before capture.',
        'captureMs measures PNG capture from the rendered RepaintBoundary/screenshot surface.',
      ],
      'selectedCount': entries.length,
      'generated': <Map<String, Object>>[],
      'failed': <Map<String, Object>>[],
      'skipped': <Map<String, Object>>[],
      'qualityWarnings': <Map<String, Object>>[],
      'performance': <Map<String, Object>>[],
      'flutterErrors': <Map<String, Object>>[],
      'launchVisualMetrics': <Map<String, Object>>[],
    };

    // Required for takeScreenshot on Android. Some desktop runners do not
    // expose this plugin; record a skipped report rather than failing setup.
    try {
      await binding.convertFlutterSurfaceToImage();
    } on MissingPluginException catch (error) {
      (report['skipped']! as List<Map<String, Object>>).add({
        'reason': 'Screenshot plugin unavailable',
        'error': error.toString(),
      });
      final outDir = _outputDirectory(
          updateAssets: updateAssets, launchMedia: launchMedia);
      _writeReport(outDir, report);
      debugPrint('Screenshot plugin unavailable; wrote thumbnail report only.');
      return;
    }

    final outDir =
        _outputDirectory(updateAssets: updateAssets, launchMedia: launchMedia);
    outDir.createSync(recursive: true);

    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final module = entry.module;
      final repaintKey = GlobalKey();
      FractalController? controller;
      try {
        final totalStopwatch = Stopwatch()..start();
        final shaderLoadStopwatch = Stopwatch()..start();
        await ui.FragmentProgram.fromAsset(module.shaderAsset);
        shaderLoadStopwatch.stop();

        final selectStopwatch = Stopwatch()..start();
        controller = FractalController(registry);
        controller.selectModule(module, animate: false);
        _applySeededColorScheme(controller, module, seed);
        selectStopwatch.stop();

        final frameTimings = <ui.FrameTiming>[];
        void timingsCallback(List<ui.FrameTiming> timings) {
          frameTimings.addAll(timings);
        }

        WidgetsBinding.instance.addTimingsCallback(timingsCallback);
        final renderWarmupStopwatch = Stopwatch()..start();
        try {
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ChangeNotifierProvider.value(
                value: controller,
                child: SizedBox(
                  width: thumbSize.toDouble(),
                  height: thumbSize.toDouble(),
                  child: FractalRenderer(
                    boundaryKey: repaintKey,
                    gesturesEnabled: false,
                  ),
                ),
              ),
            ),
          );

          // Let shader compile and render a stable frame.
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 100));
        } finally {
          WidgetsBinding.instance.removeTimingsCallback(timingsCallback);
        }
        renderWarmupStopwatch.stop();

        final captureStopwatch = Stopwatch()..start();
        final bytes = await _captureThumbnailBytes(
          binding,
          repaintKey,
          'thumb_${module.id}',
        );
        captureStopwatch.stop();
        final screenshot = img.decodeImage(Uint8List.fromList(bytes));
        if (screenshot == null) {
          throw StateError('decode failed');
        }

        final thumb = screenshot.width == thumbSize &&
                screenshot.height == thumbSize
            ? screenshot
            : img.copyResize(screenshot, width: thumbSize, height: thumbSize);
        final pngBytes = img.encodePng(thumb, level: 6);
        final outFile = File('${outDir.path}/${module.id}.png');
        outFile.writeAsBytesSync(pngBytes);
        totalStopwatch.stop();

        final flutterErrors = _takeFlutterExceptions(tester);
        final quality = _qualityWarnings(
          thumb,
          pngBytes.length,
          expectedSize: thumbSize,
        );
        final generated = report['generated']! as List<Map<String, Object>>;
        final launchMetrics = _launchMetricsFor(entry, thumb);
        final performance = <String, Object>{
          'catalogId': entry.catalogId,
          'moduleId': module.id,
          'shaderAsset': module.shaderAsset,
          'shaderLoadMs': _elapsedMs(shaderLoadStopwatch),
          'moduleSelectMs': _elapsedMs(selectStopwatch),
          'renderWarmupMs': _elapsedMs(renderWarmupStopwatch),
          'frameTimings': _frameTimingStats(frameTimings),
          'captureMs': _elapsedMs(captureStopwatch),
          'totalMs': _elapsedMs(totalStopwatch),
          'imagePath': outFile.path,
          'imageWidth': thumb.width,
          'imageHeight': thumb.height,
          'pngBytes': pngBytes.length,
        };
        (report['performance']! as List<Map<String, Object>>).add(performance);
        if (flutterErrors.isNotEmpty) {
          (report['flutterErrors']! as List<Map<String, Object>>).add({
            'catalogId': entry.catalogId,
            'moduleId': module.id,
            'errors': flutterErrors,
          });
        }
        generated.add({
          'catalogId': entry.catalogId,
          'moduleId': module.id,
          'path': outFile.path,
          'bytes': pngBytes.length,
          'warnings': quality,
          'performance': performance,
          if (flutterErrors.isNotEmpty) 'flutterErrors': flutterErrors,
          if (launchMetrics != null) 'launchVisualMetrics': launchMetrics,
        });
        if (launchMetrics != null) {
          (report['launchVisualMetrics']! as List<Map<String, Object>>).add({
            'catalogId': entry.catalogId,
            'moduleId': module.id,
            ...launchMetrics,
          });
        }
        if (quality.isNotEmpty) {
          (report['qualityWarnings']! as List<Map<String, Object>>).add({
            'catalogId': entry.catalogId,
            'moduleId': module.id,
            'warnings': quality,
          });
        }

        if ((index + 1) % 20 == 0 || index == entries.length - 1) {
          debugPrint('  Progress: ${index + 1}/${entries.length}');
        }
      } catch (error, stackTrace) {
        if (error is MissingPluginException) {
          (report['skipped']! as List<Map<String, Object>>).add({
            'catalogId': entry.catalogId,
            'moduleId': module.id,
            'reason': 'Screenshot plugin unavailable during capture',
            'error': error.toString(),
          });
          break;
        }
        debugPrint('  ERROR ${module.id}: $error');
        (report['failed']! as List<Map<String, Object>>).add({
          'catalogId': entry.catalogId,
          'moduleId': module.id,
          'error': error.toString(),
          'stack': stackTrace.toString(),
        });
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final teardownErrors = _takeFlutterExceptions(tester);
        if (teardownErrors.isNotEmpty) {
          (report['flutterErrors']! as List<Map<String, Object>>).add({
            'catalogId': entry.catalogId,
            'moduleId': module.id,
            'phase': 'teardown',
            'errors': teardownErrors,
          });
        }
        controller?.dispose();
      }
    }

    _writeReport(outDir, report);

    final generated = (report['generated']! as List).length;
    final failed = (report['failed']! as List).length;
    final skipped = (report['skipped']! as List).length;
    final qualityWarnings = (report['qualityWarnings']! as List).length;
    debugPrint('\n=== GPU Catalog Thumbnail Generation ===');
    debugPrint('Output: ${outDir.path}/');
    debugPrint(
      'Generated: $generated / Failed: $failed / Skipped: $skipped / '
      'Quality warnings: $qualityWarnings / Selected: ${entries.length}',
    );

    if (strict) {
      expect(failed, 0, reason: 'STRICT_CATALOG_THUMBS rejects failures.');
      expect(
        qualityWarnings,
        0,
        reason: 'STRICT_CATALOG_THUMBS rejects quality warnings.',
      );
    }
  });
}

Directory _outputDirectory({
  required bool updateAssets,
  bool launchMedia = false,
}) {
  if (launchMedia) {
    if (Platform.isAndroid) {
      return Directory('/sdcard/Download/launch_media');
    }
    return Directory('build/test_output/launch_media');
  }
  if (updateAssets) {
    return Directory('assets/catalog_thumbs');
  }
  if (Platform.isAndroid) {
    return Directory('/sdcard/Download/catalog_thumbs_seeded');
  }
  return Directory('build/test_output/catalog_thumbs_seeded');
}

List<CatalogEntry> _selectEntries(
  List<CatalogEntry> entries,
  Map<String, String> env, {
  bool defaultToFeatured = false,
}) {
  var only = env['CATALOG_THUMB_ONLY']
      ?.split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .map((id) => id.startsWith('core.') ? id.substring(5) : id)
      .toSet();

  // Launch-media runs with no explicit CATALOG_THUMB_ONLY default to the
  // curated featured set so marketing captures are deterministic.
  if ((only == null || only.isEmpty) && defaultToFeatured) {
    only = kFeaturedLaunchSetModuleIds.toSet();
  }

  var selected = entries;
  final ids = only;
  if (ids != null && ids.isNotEmpty) {
    selected = selected
        .where(
          (entry) =>
              ids.contains(entry.module.id) || ids.contains(entry.catalogId),
        )
        .toList(growable: false);
  }

  final offset = _envInt(env, 'CATALOG_THUMB_OFFSET') ?? 0;
  final limit = _envInt(env, 'CATALOG_THUMB_LIMIT');
  final safeOffset = offset.clamp(0, selected.length);
  final end = limit == null
      ? selected.length
      : (safeOffset + limit.clamp(0, selected.length))
          .clamp(0, selected.length);
  return selected.sublist(safeOffset, end).toList(growable: false);
}

Map<String, Object>? _launchMetricsFor(CatalogEntry entry, img.Image thumb) {
  if (!kFeaturedLaunchSetModuleIds.contains(entry.module.id)) return null;
  return LaunchVisualMetrics.fromImage(thumb).toJson();
}

Future<List<int>> _captureThumbnailBytes(
  IntegrationTestWidgetsFlutterBinding binding,
  GlobalKey repaintKey,
  String name,
) async {
  final context = repaintKey.currentContext;
  final boundary = context?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary != null) {
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('RepaintBoundary PNG encode failed for $name');
    }
    return byteData.buffer.asUint8List();
  }

  return binding.takeScreenshot(name);
}

bool _isDiagnosticModule(FractalModule module) {
  return module.id.startsWith('test_') ||
      module.id == 'gpu_gradient' ||
      module.id == 'gpu_sampler_diag' ||
      module.shaderAsset.startsWith('shaders/diagnostic/');
}

void _applySeededColorScheme(
  FractalController controller,
  FractalModule module,
  String seed,
) {
  final colorParam =
      module.parameters.where((param) => param.id == 'colorScheme').firstOrNull;
  if (colorParam == null) return;

  final random = Random(_stableSeed('$seed:${module.id}:colorScheme'));
  if (colorParam.type == FractalParamType.enumeration &&
      colorParam.options.isNotEmpty) {
    final option =
        colorParam.options[random.nextInt(colorParam.options.length)];
    controller.updateParam('colorScheme', option.value);
    return;
  }

  final min = colorParam.min.ceil();
  final max = colorParam.max.floor();
  if (max >= min) {
    controller.updateParam('colorScheme', min + random.nextInt(max - min + 1));
  }
}

int _stableSeed(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

List<String> _qualityWarnings(
  img.Image image,
  int byteLength, {
  required int expectedSize,
}) {
  final warnings = <String>[];
  if (image.width != expectedSize || image.height != expectedSize) {
    warnings.add(
        'dimensions ${image.width}x${image.height}, expected ${expectedSize}x$expectedSize');
  }
  if (byteLength < _minimumPngBytes) {
    warnings.add('png bytes $byteLength < $_minimumPngBytes');
  }

  var nonTransparent = 0;
  var luminanceSum = 0.0;
  var luminanceSquaredSum = 0.0;
  final uniqueColors = <int>{};
  final total = image.width * image.height;

  for (final pixel in image) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();
    final a = pixel.a.toInt();
    if (a > 16) {
      nonTransparent++;
    }
    uniqueColors.add((r << 16) | (g << 8) | b);
    final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    luminanceSum += luminance;
    luminanceSquaredSum += luminance * luminance;
  }

  final nonTransparentRatio = total == 0 ? 0.0 : nonTransparent / total;
  if (nonTransparentRatio < _minimumNonTransparentPixelRatio) {
    warnings.add(
      'non-transparent pixel ratio ${nonTransparentRatio.toStringAsFixed(4)} < $_minimumNonTransparentPixelRatio',
    );
  }
  if (uniqueColors.length < _minimumUniqueRgbColors) {
    warnings.add(
        'unique RGB colors ${uniqueColors.length} < $_minimumUniqueRgbColors');
  }

  final mean = total == 0 ? 0.0 : luminanceSum / total;
  final variance = total == 0 ? 0.0 : luminanceSquaredSum / total - mean * mean;
  final stdDev = sqrt(max(0.0, variance));
  if (stdDev < _minimumLuminanceStdDev) {
    warnings.add(
      'luminance stddev ${stdDev.toStringAsFixed(2)} < $_minimumLuminanceStdDev',
    );
  }

  return warnings;
}

double _elapsedMs(Stopwatch stopwatch) =>
    stopwatch.elapsedMicroseconds / Duration.microsecondsPerMillisecond;

double _durationMs(Duration duration) =>
    duration.inMicroseconds / Duration.microsecondsPerMillisecond;

Map<String, Object> _frameTimingStats(List<ui.FrameTiming> timings) {
  if (timings.isEmpty) {
    return {'count': 0};
  }
  double average(Iterable<double> values) {
    final list = values.toList(growable: false);
    return list.reduce((a, b) => a + b) / list.length;
  }

  final buildMs = timings.map((t) => _durationMs(t.buildDuration));
  final rasterMs = timings.map((t) => _durationMs(t.rasterDuration));
  final totalMs = timings.map((t) => _durationMs(t.totalSpan));
  return {
    'count': timings.length,
    'avgBuildMs': average(buildMs),
    'maxBuildMs': buildMs.reduce(max),
    'avgRasterMs': average(rasterMs),
    'maxRasterMs': rasterMs.reduce(max),
    'avgTotalSpanMs': average(totalMs),
    'maxTotalSpanMs': totalMs.reduce(max),
  };
}

List<String> _takeFlutterExceptions(WidgetTester tester) {
  final errors = <String>[];
  Object? exception;
  while ((exception = tester.takeException()) != null) {
    errors.add(exception.toString());
  }
  return errors;
}

void _writeReport(Directory outDir, Map<String, Object> report) {
  outDir.createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  File('${outDir.path}/thumbnail_report.json').writeAsStringSync(
    encoder.convert(report),
  );
}

bool _envBool(Map<String, String> env, String key) {
  final value = env[key]?.toLowerCase();
  return value == '1' || value == 'true' || value == 'yes';
}

int? _envInt(Map<String, String> env, String key) {
  final raw = env[key];
  if (raw == null || raw.isEmpty) return null;
  return int.tryParse(raw);
}
