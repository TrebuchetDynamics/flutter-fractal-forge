import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/migration/support/reference_capture.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native version, snapshots and isolated handle lifecycle',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue,
        reason: 'This fixture must exercise the real opt-in native bridge');
    final adapter = (await RustEngineAdapter.create())!;
    try {
      expect(adapter.version, '0.1.0');
      final snapshot = adapter.snapshot();
      expect(snapshot, adapter.snapshot());
      expect(snapshot.revision, BigInt.zero);
      expect(
          snapshot.view,
          const ViewState(
              centerX: 0,
              centerY: 0,
              zoom: 1,
              rotationX: 0,
              rotationY: 0,
              rotationZ: 0));
      final first = native.createEngine();
      final second = native.createEngine();
      try {
        expect(native.engineSnapshot(engine: first).sessionId,
            isNot(native.engineSnapshot(engine: second).sessionId));
        first.dispose();
        expect(() => native.engineSnapshot(engine: first), throwsA(anything));
        expect(native.engineSnapshot(engine: second).revision, BigInt.zero);
      } finally {
        if (!first.isDisposed) first.dispose();
        second.dispose();
      }
      // Preserve the original capabilities/shutdown regression too.
      final legacy = native.Engine();
      try {
        expect(legacy.capabilities().rendering, isFalse);
        legacy.shutdown();
        legacy.shutdown();
        expect(() => legacy.capabilities(),
            throwsA(contains('session is closed')));
      } finally {
        legacy.dispose();
      }
    } finally {
      adapter.shutdown();
      adapter.shutdown();
    }
    expect(() => adapter.snapshot(), throwsStateError);
  });

  testWidgets(
      'production viewer pixels/state survive the persistent neutral probe',
      (tester) async {
    expect(RuntimeModeService.forceGpuRender, isTrue,
        reason: 'Run the native wrapper with FORCE_GPU_RENDER=true');
    expect(RuntimeModeService.useRendererPlaceholderSurface, isFalse);
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(768, 768);
    tester.view.devicePixelRatio = 1;
    await binding.setSurfaceSize(const Size(768, 768));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await binding.setSurfaceSize(null);
    });
    final evidence = <String, Object?>{};
    binding.reportData ??= {};
    binding.reportData!['rust_core_viewer'] = evidence;
    final manifestText =
        await rootBundle.loadString('$referenceRoot/manifest.json');
    final manifest = jsonDecode(manifestText) as Map;
    evidence['m0_manifest_sha256'] = referenceHash(utf8.encode(manifestText));
    evidence['m0_backend'] = manifest['provenance']['backend'];
    for (final id in [
      'mandelbrot',
      'mandelbrot-edited',
      'mandelbulb',
      'mandelbulb-edited'
    ]) {
      final m0 =
          (manifest['records'] as List).singleWhere((r) => r['state_id'] == id);
      final registry = ModuleRegistry();
      final module = registry.byId(id.replaceFirst('-edited', ''));
      final preset = referencePreset(module, id);
      final inputs = referenceInputs(module, preset);
      expect(objectHash(inputs), m0['input_sha256']);
      expect(inputs, m0['inputs']);
      final controller = FractalController(registry);
      final accessibility = await AccessibilityService.create();
      await accessibility.setReducedMotion(true);
      final settings = await RendererSettingsService.create();
      final history = HistoryProvider(store: await HistoryStore.create());
      RustEngineAdapter? probe;
      try {
        expect(
            await controller.loadState(
                module: module, params: preset.params, view: preset.view),
            isTrue);
        await tester.pumpWidget(MultiProvider(
          providers: [
            Provider.value(value: registry),
            ChangeNotifierProvider.value(value: controller),
            ChangeNotifierProvider.value(value: accessibility),
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: history),
            Provider.value(value: await PresetStore.create()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FractalViewerScreen(restoreViewerSession: false),
          ),
        ));
        // Wait for a real frozen frame, not just a mounted/placeholder widget.
        for (var i = 0; i < 80; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          final finder = find.byType(FractalRenderer);
          if (finder.evaluate().length == 1 &&
              tester
                      .widget<FractalRenderer>(finder)
                      .renderSnapshotSink
                      ?.snapshot !=
                  null) break;
        }
        Future<Map<String, Object?>> capture() async {
          await tester.pump(const Duration(milliseconds: 100));
          final renderer =
              tester.widget<FractalRenderer>(find.byType(FractalRenderer));
          expect(renderer.overrideChild, isNull);
          expect(renderer.animationEnabled, isFalse);
          final snapshot = renderer.renderSnapshotSink!.snapshot!;
          expect(snapshot.time, 0);
          expect(snapshot.module.id, module.id);
          expect(controller.params, preset.params);
          expect(snapshot.state.transparentBackground, isFalse);
          expect(snapshot.glowEnabled, isFalse);
          expect(snapshot.kaleidoscopeEnabled, isFalse);
          expect(preset.copyWith(view: snapshot.state.view).toJson()['view'],
              preset.toJson()['view']);
          final boundary = renderer.boundaryKey!.currentContext!
              .findRenderObject()! as RenderRepaintBoundary;
          expect(boundary.size.width, boundary.size.height);
          final image =
              await boundary.toImage(pixelRatio: 256 / boundary.size.width);
          try {
            expect(image.width, 256);
            expect(image.height, 256);
            final png =
                (await image.toByteData(format: ui.ImageByteFormat.png))!
                    .buffer
                    .asUint8List();
            final rgba =
                (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
                    .buffer
                    .asUint8List();
            return {
              'png_base64': base64Encode(png),
              'rgba_sha256': referenceHash(rgba),
              'state': {
                'module': controller.module.id,
                'params': Map.of(controller.params),
                'view': preset.copyWith(view: controller.view).toJson()['view'],
                'effective_params': snapshot.state.params,
                'time': snapshot.time,
                'transparent': snapshot.state.transparentBackground,
                'glow': snapshot.glowEnabled,
                'kaleidoscope': snapshot.kaleidoscopeEnabled,
              },
              'backend': renderer.renderPlan!.backend.backend.name,
              'precision': renderer.renderPlan!.precision.renderPath.name,
              'width': image.width,
              'height': image.height,
            };
          } finally {
            image.dispose();
          }
        }

        final before = await capture();
        probe = (await RustEngineAdapter.create())!;
        expect(probe.version, '0.1.0');
        final neutral = probe.snapshot();
        expect(neutral, probe.snapshot());
        expect(neutral.revision, BigInt.zero);
        final during = await capture();
        probe.shutdown();
        final after = await capture();
        for (final candidate in [during, after]) {
          expect(candidate['state'], before['state']);
          expect(candidate['backend'], before['backend']);
          expect(candidate['precision'], before['precision']);
          expect(candidate['rgba_sha256'], before['rgba_sha256'],
              reason: 'Exact same-target/backend decoded pixel equality');
        }
        final m0Png = (await rootBundle.load('$referenceRoot/$id.png'))
            .buffer
            .asUint8List();
        expect(referenceHash(m0Png), m0['png_sha256']);
        final m0Image = img.decodePng(m0Png)!;
        final actualImage =
            img.decodePng(base64Decode(before['png_base64']! as String))!;
        final crossBackendVariance = referenceVariance(
            m0Image.getBytes(order: img.ChannelOrder.rgba),
            actualImage.getBytes(order: img.ChannelOrder.rgba));
        evidence[id] = {
          'm0_input_sha256': m0['input_sha256'],
          'inputs': inputs,
          'session_id': neutral.sessionId.toString(),
          'revision': neutral.revision.toString(),
          'before': before,
          'during': during,
          'after': after,
          'same_backend_equal': true,
          'cross_backend_m0_comparison': {
            'variance': crossBackendVariance,
            'reference_backend': manifest['provenance']['backend'],
            'actual_backend': before['backend'],
            'qualification':
                'Measured only; cross-backend differences are not coerced to equality',
          },
        };
      } finally {
        probe?.shutdown();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        controller.dispose();
        accessibility.dispose();
        settings.dispose();
        history.dispose();
      }
    }
  });
}
