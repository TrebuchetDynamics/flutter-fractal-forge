/// Real Linux rendering/export evidence. Run with isolated XDG preferences and
/// NUMBER_WALL_ARTIFACT_DIR; no test fonts, placeholder surface or fake exporter.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/rendering/palette/palette_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/number_walls/number_wall_presentation.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/number_wall_exact_renderer.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

import '../helpers/ui_test_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const output = String.fromEnvironment('NUMBER_WALL_ARTIFACT_DIR',
      defaultValue: 'test/results/number-wall-native');
  testWidgets('Number Walls composed native artwork journey', (tester) async {
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    final directory = await Directory(output).create(recursive: true);
    final presets = await PresetStore.create();
    final accessibility = await AccessibilityService.create();
    await accessibility.setHighContrast(false);
    await accessibility.setReducedMotion(false);
    final settings = await RendererSettingsService.create();
    final palettes = await PaletteService.create();
    final root = GlobalKey();
    final observations = <String, Object?>{
      'source': const String.fromEnvironment('NUMBER_WALL_SOURCE'),
      'os': Platform.operatingSystemVersion,
      'dart': Platform.version,
      'fontSubstitution': false,
      'gridLimit': [256, 64],
      'captures': <Object>[],
      'measurements': <Object>[],
    };
    final measurements = observations['measurements'] as List<Object>;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    await binding.setSurfaceSize(const Size(1280, 900));
    final semantics = tester.ensureSemantics();

    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> screenshot(String name) async {
      await settle();
      for (var error = tester.takeException();
          error != null;
          error = tester.takeException()) {
        if (error.toString().contains('A RenderFlex overflowed')) {
          final defects =
              (observations['layoutDefects'] ??= <Object>[]) as List<Object>;
          defects.add({'state': name, 'error': error.toString()});
        } else {
          fail('$name: $error');
        }
      }
      final boundary =
          root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      final context = tester.element(find.byType(Scaffold).last);
      final media = MediaQuery.of(context);
      (observations['captures'] as List<Object>).add({
        'file': '$name.png',
        'dimensions': [image.width, image.height],
        'locale': Localizations.localeOf(context).toLanguageTag(),
        'textScale': media.textScaler.scale(10) / 10,
        'highContrast': accessibility.highContrastEnabled,
      });
      image.dispose();
    }

    try {
      await const ExportService()
          .setPreferredExportDirectory(Directory('${directory.path}/saved'));
      await tester.pumpWidget(RepaintBoundary(
        key: root,
        child: FlutterFractalsApp(
          presetStore: presets,
          accessibilityService: accessibility,
          rendererSettingsService: settings,
          locale: const Locale('en'),
        ),
      ));
      await pumpForAppBoot(tester);
      await enterCatalogSearch(tester, 'Number Walls');
      final card = catalogModuleCard('core.number_wall');
      await tester.ensureVisible(card);
      final catalogClock = Stopwatch()..start();
      final computing = find.descendant(
          of: card, matching: find.text('Computing exact finite-field wall…'));
      while (computing.evaluate().isNotEmpty &&
          catalogClock.elapsed < const Duration(minutes: 2)) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(computing, findsNothing,
          reason:
              'Use FORCE_RUNTIME_CATALOG_THUMBNAILS=true; retain a real card, not a placeholder.');
      observations['catalogPreviewReadyMs'] = catalogClock.elapsedMilliseconds;
      await screenshot('catalog-en');
      final clock = Stopwatch()..start();
      await tester.tap(card);
      await settle();
      final controller = tester
          .element(find.byType(NumberWallExactRenderer))
          .read<FractalController>();
      final wall = controller.module;

      Future<void> complete(String name) async {
        final watch = Stopwatch()..start();
        while (controller.numberWallPending &&
            watch.elapsed < const Duration(minutes: 5)) {
          await tester.pump(const Duration(milliseconds: 20));
        }
        expect(controller.numberWallPending, isFalse, reason: name);
        expect(controller.numberWallGrid, isNotNull, reason: name);
        measurements.add({
          'job': name,
          'elapsedMs': watch.elapsedMilliseconds,
          'rssBytes': ProcessInfo.currentRss,
          'maxRssBytes': ProcessInfo.maxRss,
        });
        await settle();
      }

      await complete('catalog-default');
      observations['catalogToGridMs'] = clock.elapsedMilliseconds;

      Future<void> exportAndRecord(String name) async {
        final grid = controller.numberWallGrid!;
        final style = NumberWallStyle.fromParams(controller.params);
        expect(grid.prime, lessThanOrEqualTo(BigInt.from(97)),
            reason:
                'This journey uses a bounded complete residue colour table.');
        // This boundary is the actual viewer (including the GPU sampler), not
        // another invocation of the export painter.
        await settle();
        final plot = find.byKey(const Key('numberWallExactPlot'));
        final boundary = tester.renderObject<RenderRepaintBoundary>(find
            .ancestor(of: plot, matching: find.byType(RepaintBoundary))
            .first);
        final viewer = await boundary.toImage(pixelRatio: 1);
        final viewerBytes =
            await viewer.toByteData(format: ui.ImageByteFormat.png);
        final viewerPng = img.decodePng(viewerBytes!.buffer.asUint8List())!;
        viewer.dispose();
        final paints = tester.widgetList<CustomPaint>(
            find.descendant(of: plot, matching: find.byType(CustomPaint)));
        final painter =
            paints.map((p) => p.painter).whereType<NumberWallPainter>().single;
        final backend = painter.shader == null ? 'Canvas' : 'GPU sampler';
        final existing = await Directory('${directory.path}/saved')
            .list()
            .map((e) => e.path)
            .toSet();
        await tester.tap(find.byKey(const Key('viewerOverflowMenu')));
        await settle();
        await tester.tap(find.text('Export').last);
        await settle();
        await tester.ensureVisible(find.text('Customize'));
        await tester.tap(find.text('Customize'));
        await settle();
        await tester.ensureVisible(find.text(ExportResolution.hd.displayName));
        await tester.tap(find.text(ExportResolution.hd.displayName));
        await settle();
        final save = find.byKey(const ValueKey('exportSaveButton'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        File? saved;
        for (var i = 0; i < 300 && saved == null; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          final files = await Directory('${directory.path}/saved')
              .list()
              .where((e) =>
                  e is File &&
                  !existing.contains(e.path) &&
                  e.path.endsWith('.png'))
              .cast<File>()
              .toList();
          if (files.isNotEmpty) saved = files.single;
        }
        expect(saved, isNotNull);
        final pngBytes = await saved!.readAsBytes();
        final png = img.decodePng(pngBytes)!;
        expect((png.width, png.height), (1280, 720));
        for (final image in [viewerPng, png]) {
          final rect = numberWallFieldRect(
              Size(image.width.toDouble(), image.height.toDouble()),
              controller.view);
          for (var row = 0; row < grid.rowCount; row++) {
            for (var col = 0; col < grid.columnCount; col++) {
              final pixel = image.getPixel(
                  (rect.left + (col + .5) * rect.width / grid.columnCount)
                      .floor(),
                  (rect.top + (row + .5) * rect.height / grid.rowCount)
                      .floor());
              final color = style.cellColor(grid.values[row][col], grid.prime);
              // Skia/texture float-to-byte quantization can differ by 1 LSB.
              // This is a colour tolerance, never a residue/zero-mask tolerance.
              final expected = [
                (color.r * 255).round(),
                (color.g * 255).round(),
                (color.b * 255).round()
              ];
              final actual = [pixel.r, pixel.g, pixel.b];
              for (var channel = 0; channel < 3; channel++) {
                expect((actual[channel] - expected[channel]).abs(),
                    lessThanOrEqualTo(1),
                    reason: '$name $backend cell $row,$col channel $channel');
              }
              expect(pixel.a, 255);
            }
          }
        }
        await File('${directory.path}/$name.png').writeAsBytes(pngBytes);
        await File('${directory.path}/$name.json').writeAsString(jsonEncode({
          'params': controller.params,
          'view': {
            'pan': [controller.view.pan.x, controller.view.pan.y],
            'zoom': controller.view.zoom,
            'rotation': [0, 0, 0]
          },
          'prime': grid.prime.toString(),
          'matrix': grid.values
              .map((r) => r.map((v) => v.toString()).toList())
              .toList(),
          // All field residues, including those absent in this matrix: web
          // readback must not mistake an unseen residue for a matching colour.
          'colors': {
            for (var v = 0; v < grid.prime.toInt(); v++)
              v.toString():
                  style.cellColor(BigInt.from(v), grid.prime).toARGB32()
          },
          'rgbToleranceLsb': 1,
          'backend': backend,
          'dimensions': [png.width, png.height],
        }));
        await settle();
        expect(find.byType(ExportOptionsSheet), findsNothing);
        final randomButton = find.byKey(const Key('viewerRandomParamsButton'));
        for (var i = 0;
            i < 100 && randomButton.hitTestable().evaluate().isEmpty;
            i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(randomButton.hitTestable(), findsOneWidget);
      }

      for (final source in [
        'signedPagoda',
        'rook',
        'thueMorse',
        'rudinShapiro',
        'fibonacci',
        'squares'
      ]) {
        await tester
            .longPress(find.byKey(const Key('viewerRandomParamsButton')));
        await settle();
        final l10n = AppLocalizations.of(
            tester.element(find.byType(NumberWallExactRenderer)))!;
        final option = wall.parameters
            .firstWhere((p) => p.id == 'source')
            .options
            .singleWhere((o) => o.value == source);
        final chip = find.text(option.label(l10n));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await complete(source);
        expect(controller.params['source'], source);
        await tester.tap(find.descendant(
            of: find.byType(FractalControlsHud),
            matching: find.byTooltip('Close this dialog')));
        await settle();
        await exportAndRecord(source);
      }
      // Real stored-preset replay uses the same certification seam as imports.
      final committed = controller.numberWallGrid;
      for (final prime in ['561', '170141183460469231731687303715884105727']) {
        final replay = FractalPreset.fromJson({
          ...wall.defaultPreset.toJson(),
          'id': 'rejected-$prime',
          'name': 'Rejected replay',
          'params': {...controller.params, 'prime': prime},
        });
        await presets.saveUserPreset(replay);
        final loaded = (await presets.loadUserPresets('number_wall'))
            .singleWhere((p) => p.id == replay.id);
        await controller.applyPreset(loaded);
        expect(controller.numberWallGrid, same(committed));
        expect(controller.params['prime'], '2');
        expect(
            controller.numberWallStatus,
            prime == '561'
                ? NumberWallPrimeStatus.composite
                : NumberWallPrimeStatus.unverified);
      }
      final replay = FractalPreset.fromJson({
        ...wall.defaultPreset.toJson(),
        'id': 'outside-quick-picks',
        'name': 'Outside quick picks',
        'params': {
          ...wall.defaultPreset.params,
          'prime': '97',
          'colorMode': 1,
          'rows': 4,
          'columns': 16
        },
      });
      await presets.saveUserPreset(replay);
      final replayClock = Stopwatch()..start();
      await controller.applyPreset(
          (await presets.loadUserPresets('number_wall'))
              .singleWhere((p) => p.id == replay.id));
      await complete('replay-97');
      measurements.add({
        'job': 'replay-97-total',
        'elapsedMs': replayClock.elapsedMilliseconds
      });
      await exportAndRecord('replay-97');
      await tester.tap(find.byKey(const Key('viewerColorCycleButton')));
      await settle();
      final beforeRandom = Map<String, Object>.of(controller.params);
      final beforeGrid = controller.numberWallGrid;
      await tester.tap(find.byKey(const Key('viewerRandomParamsButton')));
      await complete('ui-randomize');
      expect(controller.canUndoNumberWallRandomization, isTrue);
      await tester.longPress(find.byKey(const Key('viewerRandomParamsButton')));
      await settle();
      final undo = find.text('Undo randomization');
      await tester.ensureVisible(undo);
      await tester.tap(undo);
      await tester.tap(find.descendant(
          of: find.byType(FractalControlsHud),
          matching: find.byTooltip('Close this dialog')));
      await settle();
      expect(controller.params, beforeRandom);
      expect(controller.numberWallGrid, same(beforeGrid));
      final savedStyle = FractalPreset(
          id: 'saved-style',
          moduleId: 'number_wall',
          name: 'Saved style',
          params: beforeRandom,
          view: controller.view,
          createdAt: DateTime.utc(2026));
      await presets.saveUserPreset(savedStyle);
      await controller.applyPreset(
          (await (await PresetStore.create()).loadUserPresets('number_wall'))
              .singleWhere((p) => p.id == savedStyle.id));
      await exportAndRecord('styled-97');
      await screenshot('viewer-en');
      // Inspect a real displayed cell and retain the honest exact-backend label.
      final plot = find.byKey(const Key('numberWallExactPlot'));
      await tester.tapAt(tester.getCenter(plot));
      await settle();
      expect(
          find.textContaining('Cell m=2, n=72, p=97, residue='
              '${controller.numberWallGrid!.values[2][8]}.'),
          findsOneWidget);
      await screenshot('inspector-en');

      unawaited(controller.loadState(
          module: wall,
          params: {
            ...wall.defaultPreset.params,
            'source': 'squares',
            'columns': 256,
            'rows': 64,
          },
          view: wall.defaultPreset.view));
      await complete('completed-zero-window-256x64');
      expect(controller.numberWallGrid!.values.length, 64);
      await controller.applyPreset(replay);

      // Cancellation is scheduled on the event loop, not an immediately true
      // test callback: the computation must actually yield to another task.
      for (final job in ['large-prime', 'zero-window-256x64']) {
        final retained = controller.numberWallGrid;
        final watch = Stopwatch()..start();
        Timer? timer;
        int? deliveredMs;
        final pending = job == 'large-prime'
            ? controller
                .applyNumberWallPrime('170141183460469231731687303715884105727')
            : controller.loadState(
                module: wall,
                params: {
                  ...controller.params,
                  'source': 'squares',
                  'prime': '2',
                  'columns': 256,
                  'rows': 64,
                },
                view: controller.view);
        timer = Timer(const Duration(milliseconds: 50), () {
          deliveredMs = watch.elapsedMilliseconds;
          controller.cancelNumberWallRequest();
        });
        await pending;
        timer.cancel();
        final settledMs = watch.elapsedMilliseconds;
        expect(deliveredMs, isNotNull);
        // A generous debug-host regression bound, not a production speed score.
        expect(deliveredMs, lessThan(2000));
        expect(controller.numberWallGrid, same(retained));
        expect(controller.numberWallPending, isFalse);
        expect(watch.elapsedMilliseconds - deliveredMs!, lessThan(2000));
        await tester.pump(const Duration(milliseconds: 200));
        expect(controller.numberWallGrid, same(retained));
        measurements.add({
          'job': job,
          'cancelDeliveredMs': deliveredMs,
          'settledMs': settledMs,
          'staleGuardMs': 200,
          'rssBytes': ProcessInfo.currentRss
        });
      }
      // Actual app typography/rendering, synthetic viewport/accessibility
      // inputs. These are not physical-device or screen-reader qualification.
      await accessibility.setHighContrast(true);
      tester.view.physicalSize = const Size(320, 900);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await binding.setSurfaceSize(const Size(320, 900));
      await tester.longPress(find.byKey(const Key('viewerRandomParamsButton')));
      await screenshot('narrow-en-high-contrast-2x');
      await tester.pumpWidget(RepaintBoundary(
          key: root,
          child: FlutterFractalsApp(
              presetStore: presets,
              accessibilityService: accessibility,
              rendererSettingsService: settings,
              locale: const Locale('es'))));
      await screenshot('narrow-es-high-contrast-2x');
      expect(find.text('Secuencia'), findsOneWidget);
      observations['completed'] = true;
      await File('${directory.path}/environment.json').writeAsString(
          const JsonEncoder.withIndent('  ').convert(observations));
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      semantics.dispose();
      accessibility.dispose();
      settings.dispose();
      palettes.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await binding.setSurfaceSize(null);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
