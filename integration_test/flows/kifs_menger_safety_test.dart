import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

/// One real process launch. FDROID-002 runs this three times; a widget remount
/// is not a cold start. Do not resize the device or shorten the 60-second soaks.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'installed KIFS presets, extremes, gestures and re-entry stay healthy',
      (tester) async {
    // This journey tests rendering, not the host IME. Prevent native keyboard
    // callbacks from replacing injected catalog queries after a cold start.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    const launch = int.fromEnvironment('KIFS_COLD_START', defaultValue: 1);
    expect(launch, inInclusiveRange(1, 3));
    expect(RuntimeModeService.forceGpuRender, isTrue);
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    final started = DateTime.now().toUtc();
    final process = pid;
    final samples = <Map<String, Object?>>[];
    final soaks = <Map<String, Object>>[];
    final report = <String, dynamic>{
      'source': const String.fromEnvironment('KIFS_SOURCE',
          defaultValue: 'unspecified'),
      'coldStart': launch,
      'startedUtc': started.toIso8601String(),
      'pid': process,
      'physicalViewport': [
        tester.view.physicalSize.width,
        tester.view.physicalSize.height,
      ],
      'devicePixelRatio': tester.view.devicePixelRatio,
      'samples': samples,
      'soaks': soaks,
      'complete': false,
    };
    binding.reportData = report;
    print('KIFS_START ${jsonEncode(report)}');

    final presets = await PresetStore.create();
    final accessibility = await AccessibilityService.create();
    final settings = await RendererSettingsService.create();
    final previousBackend = settings.backendMode;
    addTearDown(() => settings.setBackendMode(previousBackend));
    await settings.setBackendMode(RendererBackendMode.gpuOnly);
    await tester.pumpWidget(FlutterFractalsApp(
      presetStore: presets,
      accessibilityService: accessibility,
      rendererSettingsService: settings,
      locale: const Locale('en'),
      skipSplash: true,
    ));
    await pumpForAppBoot(tester);
    final renderer = find.byType(FractalRenderer);
    FractalController controller() =>
        tester.element(renderer).read<FractalController>();

    Future<void> capture(String state) async {
      await pumpForUiTransition(tester);
      expect(tester.takeException(), isNull, reason: state);
      expect(pid, process);
      expect(renderer, findsOneWidget);
      final widget = tester.widget<FractalRenderer>(renderer);
      final snapshot = widget.renderSnapshotSink?.snapshot;
      expect(snapshot, isNotNull, reason: 'No effective shader frame: $state');
      expect(snapshot!.module.id, controller().module.id);
      for (final key in ['power', 'steps']) {
        expect(snapshot.state.params[key], controller().params[key],
            reason: state);
      }
      final boundary = widget.boundaryKey!.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      // Capture only the actual renderer, without viewer chrome or badges.
      final frame =
          await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
      try {
        final data = await frame.toByteData(format: ui.ImageByteFormat.rawRgba);
        expect(data, isNotNull);
        final bytes = data!.buffer.asUint8List();
        final colors = <int>{};
        var foreground = 0;
        var opaque = 0;
        var count = 0;
        var rgbHash = 0x811c9dc5;
        // Sample about 256 columns without resizing the native capture.
        final stride = (frame.width / 256).ceil().clamp(1, frame.width);
        for (var y = 0; y < frame.height; y += stride) {
          final edge = y * frame.width * 4;
          for (var x = 0; x < frame.width; x += stride) {
            final i = (y * frame.width + x) * 4;
            final rgb = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2];
            colors.add(rgb);
            rgbHash = ((rgbHash ^ rgb) * 0x01000193) & 0xffffffff;
            // KIFS and both controls have a vertical-only miss gradient.
            // Same-row contrast cannot count that background as geometry.
            if ((bytes[i] - bytes[edge]).abs() +
                    (bytes[i + 1] - bytes[edge + 1]).abs() +
                    (bytes[i + 2] - bytes[edge + 2]).abs() >
                24) foreground++;
            if (bytes[i + 3] == 255) opaque++;
            count++;
          }
        }
        final sample = <String, Object?>{
          'state': state,
          'utc': DateTime.now().toUtc().toIso8601String(),
          'pid': pid,
          'module': snapshot.module.id,
          'params': snapshot.state.params,
          'effectiveFractalType': snapshot.state.params['fractalType'] ??
              snapshot.module.defaultPreset.params['fractalType'] ??
              0,
          'rgbHash': rgbHash,
          'pan': [snapshot.state.view.pan.x, snapshot.state.view.pan.y],
          'zoom': snapshot.state.view.zoom,
          'rotation': [
            snapshot.state.view.rotation.x,
            snapshot.state.view.rotation.y,
            snapshot.state.view.rotation.z,
          ],
          'pixels': [frame.width, frame.height],
          'sampledPixels': count,
          'rgbColors': colors.length,
          'opaquePixels': opaque,
          'horizontalForegroundFraction': foreground / count,
        };
        samples.add(sample);
        print('KIFS_SAMPLE ${jsonEncode(sample)}');
        expect(colors.length, greaterThan(16), reason: state);
        expect(opaque, count, reason: state);
        expect(foreground / count, greaterThan(0.005),
            reason: 'Blank/background-only renderer: $state');
      } finally {
        frame.dispose();
      }
    }

    Future<void> enter(String query, String id) async {
      await enterCatalogSearch(tester, query);
      final card = catalogModuleCard('core.$id');
      await tester.ensureVisible(card);
      await tester.tap(card);
      // Shader loading is asynchronous; bound the wait and reject no-frame output.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (renderer.evaluate().length == 1 &&
            tester
                    .widget<FractalRenderer>(renderer)
                    .renderSnapshotSink
                    ?.snapshot
                    ?.module
                    .id ==
                id) break;
      }
      expect(controller().module.id, id);
      await capture('$id-entry');
    }

    Future<void> leave() async {
      await tester.binding.handlePopRoute();
      await pumpForUiTransition(tester);
      expect(renderer, findsNothing);
      expect(catalogModuleCards(), findsWidgets);
    }

    Future<void> gestures() async {
      final before = controller().view;
      final center = tester.getCenter(renderer);
      await tester.dragFrom(center, const Offset(24, 12));
      await pumpForUiTransition(tester);
      expect((controller().view.rotation - before.rotation).length,
          greaterThan(0));
      final a =
          await tester.startGesture(center - const Offset(80, 0), pointer: 1);
      final b =
          await tester.startGesture(center + const Offset(80, 0), pointer: 2);
      await tester.pump(const Duration(milliseconds: 100));
      // Cross touch slop, then deliver an update after recognition starts.
      await a.moveTo(center + const Offset(-50, 20));
      await b.moveTo(center + const Offset(70, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await a.moveTo(center + const Offset(-40, 20));
      await b.moveTo(center + const Offset(60, 20));
      await tester.pump(const Duration(milliseconds: 100));
      await a.up();
      await b.up();
      await pumpForUiTransition(tester);
      expect(controller().view.zoom, isNot(closeTo(before.zoom, 1e-6)));
      expect((controller().view.pan - before.pan).length, greaterThan(0));
    }

    Future<void> soak(String state) async {
      await capture('$state-before');
      final watch = Stopwatch()..start();
      await gestures();
      var tick = 0;
      while (watch.elapsed < const Duration(seconds: 60)) {
        await tester.dragFrom(
            tester.getCenter(renderer), Offset(tick.isEven ? -32 : 32, 0));
        await tester.pump(const Duration(seconds: 2));
        await capture('$state-soak-${tick++}');
      }
      watch.stop();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(60000));
      expect(tick, greaterThan(0));
      soaks.add({
        'state': state,
        'elapsedMs': watch.elapsedMilliseconds,
        'interactionSamples': tick,
        'pid': pid
      });
      await capture('$state-after');
    }

    await enter('KIFS Menger Sponge', 'kifs_menger');
    // Catalog re-entry can restore a tab. Explicitly select the registered default.
    await controller().applyPreset(controller().module.defaultPreset);
    await soak('default');
    await openViewerPresets(tester);
    final cathedral = find.text('Cathedral');
    await tester.ensureVisible(cathedral);
    await tester.tap(cathedral);
    await pumpForUiTransition(tester);
    expect(controller().params['steps'], 150);
    expect(controller().params['iterations'], 8);
    expect(controller().view.zoom, 2);
    await soak('cathedral');

    final module = controller().module;
    for (final scale in [2.0, 5.0]) {
      final folds = module.parameters.singleWhere((p) => p.id == 'iterations');
      final steps = module.parameters.singleWhere((p) => p.id == 'steps');
      for (final iterations in [folds.min, folds.max]) {
        for (final rays in [steps.min, steps.max]) {
          await controller().applyPreset(module.defaultPreset);
          // Use the controller's public editing seam for exact inclusive bounds.
          controller().updateParam('power', scale);
          controller().updateParam('iterations', iterations);
          controller().updateParam('steps', rays);
          expect(controller().params['power'], scale);
          expect(controller().params['iterations'], iterations);
          expect(controller().params['steps'], rays);
          await capture('extreme-$scale-$iterations-$rays');
        }
      }
    }
    await leave();
    await enter('KIFS Menger Sponge', 'kifs_menger');
    await capture('kifs-reentered');
    await leave();
    await enter('Menger Cross 3D', 'f0597_sierpinski_carpet_3d_menger_cross');
    // Fixed variants are not editable params; the uniform setter uses the
    // registered default when the controller omits that key.
    expect(samples.last['effectiveFractalType'], 1);
    expect(samples.last['rgbHash'], isNot(samples.first['rgbHash']));
    await leave();
    await enter('Mandelbulb', 'mandelbulb');
    await leave();
    expect(soaks.map((s) => s['state']), ['default', 'cathedral']);
    expect(samples.where((s) => (s['state'] as String).startsWith('extreme-')),
        hasLength(8));
    expect(pid, process);
    expect(tester.takeException(), isNull);
    report.addAll({
      'endedUtc': DateTime.now().toUtc().toIso8601String(),
      'survived': true,
      'complete': true,
    });
    print('KIFS_COMPLETE ${jsonEncode(report)}');
  }, timeout: const Timeout(Duration(minutes: 8)));
}
