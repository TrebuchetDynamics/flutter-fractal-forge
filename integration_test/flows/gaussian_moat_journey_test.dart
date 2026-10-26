import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/gaussian_moat_model.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/gaussian_moat_plot.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Gaussian catalog journey walks, pauses growth, and exports its selected PNG',
    (tester) async {
      binding.platformDispatcher.semanticsEnabledTestValue = false;
      SharedPreferences.setMockInitialValues({});
      final presetStore = await PresetStore.create();
      final accessibility = await AccessibilityService.create();
      final settings = await RendererSettingsService.create();
      addTearDown(() {
        accessibility.dispose();
        settings.dispose();
      });

      final tempRoot = Platform.environment['TMPDIR'];
      expect(tempRoot, isNotEmpty, reason: 'use task-scoped temporary storage');
      final exportDirectory = Directory(
        '$tempRoot/gaussian-moat-journey-$pid-${DateTime.now().microsecondsSinceEpoch}',
      );
      await exportDirectory.create(recursive: true);
      addTearDown(() => exportDirectory.delete(recursive: true));
      await ExportService().setPreferredExportDirectory(exportDirectory);
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibility,
        rendererSettingsService: settings,
        locale: const Locale('en'),
        skipSplash: true,
      ));
      await pumpForAppBoot(tester);

      // Enter through the actual catalog card; this guards the bypass that
      // previously mounted FractalViewerScreen with the module preselected.
      await enterCatalogSearch(tester, 'Gaussian Prime Lattice');
      final card = catalogModuleCard('core.gaussian_prime_lattice');
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await pumpForUiTransition(tester, settle: const Duration(seconds: 2));
      final renderer = find.byType(FractalRenderer);
      expect(renderer, findsOneWidget);
      final controller = Provider.of<FractalController>(
        tester.element(renderer),
        listen: false,
      );
      expect(controller.module.id, 'gaussian_prime_lattice');

      await tester.tap(find.text('Walk'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ready:'), findsOneWidget);
      expect(find.textContaining('boundary'), findsOneWidget);
      final stepControl = find.widgetWithText(TextButton, 'Step to candidate');
      final stepBounds = tester.getSize(stepControl);
      expect(stepBounds.width, greaterThanOrEqualTo(48));
      expect(stepBounds.height, greaterThanOrEqualTo(48),
          reason:
              'the accessible Step action target must be at least 48px tall');
      final beforeState = _walkState(tester);
      final beforeWalk = await _exportHdPng(tester, exportDirectory);
      expect(_walkState(tester), beforeState,
          reason: 'Export must retain the exact pre-walk state');

      // Candidate input is also the keyboard-accessible route to the same
      // exact lattice point: 1+i to 1-i has squared distance four.
      await tester.enterText(find.byKey(const Key('gaussianCoordinateA')), '1');
      await tester.enterText(
          find.byKey(const Key('gaussianCoordinateB')), '-1');
      await tester.tap(find.text('Select candidate'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Candidate: (1, -1)'), findsOneWidget);
      await _pressStep(tester);
      expect(find.textContaining('Path: 1 steps'), findsOneWidget);

      await tester.tap(find.text('Play radius growth'));
      await tester.pump(const Duration(milliseconds: 650));
      await tester.tap(find.text('Pause radius growth'));
      await tester.pumpAndSettle();
      expect(find.text('Play radius growth'), findsOneWidget);
      await _pressStep(tester);
      expect(find.textContaining('Path: 1 steps'), findsOneWidget);

      final pausedState = _walkState(tester);
      final pausedPng = await _exportHdPng(tester, exportDirectory);
      await tester.pump(const Duration(milliseconds: 1300));
      expect(_walkState(tester), pausedState,
          reason:
              'Export and elapsed growth ticks must preserve the frozen state');
      final beforeDecoded = image.decodePng(await beforeWalk.readAsBytes());
      final pausedDecoded = image.decodePng(await pausedPng.readAsBytes());
      expect(beforeDecoded, isNotNull);
      expect(pausedDecoded, isNotNull);
      expect(pausedDecoded!.width, 1280);
      expect(pausedDecoded.height, 720);
      expect(_hasVisiblePixels(pausedDecoded), isTrue);
      expect(_pngsDiffer(beforeDecoded!, pausedDecoded), isTrue,
          reason: 'PNG must reflect the committed path in the paused snapshot');
      if (const bool.fromEnvironment('GAUSSIAN_RETAIN_EVIDENCE')) {
        final outputs = Platform.environment['FLUTTER_TEST_OUTPUTS_DIR'];
        expect(outputs, isNotEmpty);
        final evidence =
            await Directory('$outputs/gaussian').create(recursive: true);
        await beforeWalk.copy('${evidence.path}/pre-walk.png');
        await pausedPng.copy('${evidence.path}/paused-growth.png');
        await File('${evidence.path}/state.json')
            .writeAsString(const JsonEncoder.withIndent('  ').convert({
          'pre_walk': beforeState,
          'paused_growth': pausedState,
          'export_state_equivalent': true,
          'paused_after_1300ms_equivalent': true,
          'dimensions': [pausedDecoded.width, pausedDecoded.height],
        }));
        await File('${evidence.path}/telemetry.json').writeAsString(
            const JsonEncoder.withIndent('  ')
                .convert(await _measureBoundedExecution()));
      }
      expect(tester.takeException(), isNull);
    },
  );
}

Map<String, Object?> _walkState(WidgetTester tester) {
  final plot = find.byKey(const Key('gaussianMoatPlot'));
  final painter =
      tester.widget<CustomPaint>(plot).painter! as GaussianMoatPainter;
  List<int> point(GaussianInteger p) => [p.a, p.b];
  return {
    'bound': painter.map.bound,
    'point_count': painter.map.points.length,
    'root': point(painter.root),
    'candidate': painter.candidate == null ? null : point(painter.candidate!),
    'path': painter.path.map(point).toList(),
    'component': painter.component.map(point).toList(),
    'squared_step': tester
        .widget<Slider>(find.byKey(const Key('gaussianGrowthScrubber')))
        .value
        .toInt(),
    'playing': find.text('Pause radius growth').evaluate().isNotEmpty,
    'pan': [painter.view.pan.x, painter.view.pan.y],
    'zoom': painter.view.zoom,
    'plot_size': [tester.getSize(plot).width, tester.getSize(plot).height],
    'foreground_argb': painter.foreground.toARGB32(),
    'background_argb': painter.background.toARGB32(),
    'highlight_argb': painter.highlight.toARGB32(),
  };
}

// Opt-in native-process observations, separate from UI latency or hardware claims.
Future<Map<String, Object?>> _measureBoundedExecution() async {
  final rssBefore = ProcessInfo.currentRss;
  final chunks = <Map<String, Object>>[];
  final yieldUs = <int>[];
  final generation = Stopwatch()..start();
  final map = (await GaussianPrimeMap.generate(128, onChunk: (chunk) {
    chunks.add({
      'probes': chunk.probes,
      'elapsed_us': chunk.elapsedMicroseconds,
      'yielded': chunk.yielded,
    });
  }, yieldChunk: () async {
    final clock = Stopwatch()..start();
    await Future<void>.delayed(Duration.zero);
    yieldUs.add(clock.elapsedMicroseconds);
  }))!;
  final generationUs = generation.elapsedMicroseconds;
  final rssAfterGeneration = ProcessInfo.currentRss;
  final searches = <Map<String, int>>[];
  for (final radius in GaussianMoatGrowth.radii) {
    final search = Stopwatch()..start();
    final component = map.component((a: 1, b: 1), maxSquaredStep: radius);
    searches.add({
      'squared_step': radius,
      'component_size': component.length,
      'elapsed_us': search.elapsedMicroseconds,
    });
  }
  final suspended = Completer<void>();
  final release = Completer<void>();
  final publications = <int>[];
  var cancellationYields = 0;
  final jobs = GaussianMoatMapJobQueue((bound, {isCancelled}) {
    return GaussianPrimeMap.generate(bound, isCancelled: isCancelled,
        yieldChunk: () async {
      cancellationYields++;
      suspended.complete();
      await release.future;
    });
  }, (bound, _) => publications.add(bound));
  jobs.submit(128);
  await suspended.future;
  final cancellation = Stopwatch()..start();
  jobs.cancel();
  release.complete();
  await jobs.idle;
  final cancellationUs = cancellation.elapsedMicroseconds;
  jobs.dispose();
  final glx = await Process.run('glxinfo', ['-B']);
  return {
    'host': Platform.localHostname,
    'os': Platform.operatingSystemVersion,
    'pid': pid,
    'backend_probe': {
      'command': 'glxinfo -B',
      'exit_code': glx.exitCode,
      'stdout': glx.stdout.toString(),
      'stderr': glx.stderr.toString()
    },
    'bound': map.bound,
    'point_count': map.points.length,
    'generation_us': generationUs,
    'chunks': chunks,
    'yield_wait_us': yieldUs,
    'searches': searches,
    'cancellation_to_idle_us': cancellationUs,
    'cancellation_yields': cancellationYields,
    'cancelled_publications': publications,
    'rss_before_bytes': rssBefore,
    'rss_after_generation_bytes': rssAfterGeneration,
    'rss_after_search_bytes': ProcessInfo.currentRss,
    'process_max_rss_bytes': ProcessInfo.maxRss,
  };
}

Future<void> _pressStep(WidgetTester tester) async {
  final step = find.text('Step to candidate');
  Focus.of(tester.element(step)).requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

Future<File> _exportHdPng(
  WidgetTester tester,
  Directory exportDirectory,
) async {
  final existing = (await exportDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList())
      .map((file) => file.path)
      .toSet();
  final export = find.text('Export').last;
  Focus.of(tester.element(export)).requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Customize'));
  await tester.tap(find.text('Customize'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text(ExportResolution.hd.displayName));
  await tester.tap(find.text(ExportResolution.hd.displayName));
  await tester.pumpAndSettle();
  final save = find.byKey(const ValueKey('exportSaveButton'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pump();
  for (var attempt = 0; attempt < 30; attempt++) {
    final files = await exportDirectory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    for (final file in files) {
      if (!existing.contains(file.path) &&
          file.path.contains('gaussian_prime_lattice') &&
          file.path.endsWith('.png')) return file;
    }
    await tester.pump(const Duration(seconds: 1));
  }
  fail('No Gaussian PNG saved in ${exportDirectory.path}');
}

bool _pngsDiffer(image.Image a, image.Image b) {
  if (a.width != b.width || a.height != b.height) return true;
  for (var y = 0; y < a.height; y += 2) {
    for (var x = 0; x < a.width; x += 2) {
      final left = a.getPixel(x, y);
      final right = b.getPixel(x, y);
      if (left.r != right.r ||
          left.g != right.g ||
          left.b != right.b ||
          left.a != right.a) return true;
    }
  }
  return false;
}

bool _hasVisiblePixels(image.Image decoded) {
  for (var y = 0; y < decoded.height; y += 4) {
    for (var x = 0; x < decoded.width; x += 4) {
      if (decoded.getPixel(x, y).a > 0) return true;
    }
  }
  return false;
}
