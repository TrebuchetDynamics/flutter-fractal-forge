import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/features/renderer/models/fractal_render_snapshot.dart';
import 'package:flutter_fractals/features/renderer/widgets/canvas/fractal_canvas.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fractal_controller_widget_harness.dart';

// Intentionally not auto-discovered: the ordinary widget suite uses placeholders.
// Run explicitly with --dart-define=FORCE_GPU_RENDER=true.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() ready,
  String outcome,
) async {
  for (var i = 0; i < 100; i++) {
    // Asset futures need real event-loop turns; retry backoff uses fake time.
    await tester.runAsync(() => Future<void>(() {}));
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) return;
  }
  fail('Renderer did not reach $outcome after 100 bounded pumps');
}

FractalModule unavailableCopy(FractalModule source) => FractalModule(
      id: 'shader_cache_recovery_missing',
      shaderAsset: 'shaders/test_only/shader_cache_recovery_missing.frag',
      displayName: source.displayName,
      dimension: source.dimension,
      horizontalOrbitSign: source.horizontalOrbitSign,
      animationCapability: source.animationCapability,
      hidesEffectControls: source.hidesEffectControls,
      parameters: source.parameters,
      defaultPreset: source.defaultPreset,
      builtInPresets: source.builtInPresets,
      setUniforms: source.setUniforms,
    );

void main() {
  testWidgets('failed shader recovers through cached and cold program installs',
      (tester) async {
    expect(const bool.fromEnvironment('FORCE_GPU_RENDER'), isTrue,
        reason: 'Run this dedicated file with FORCE_GPU_RENDER=true');
    final harness = FractalControllerWidgetHarness();
    final controller = harness.controller;
    final mandelbrot = harness.registry.byId('mandelbrot');
    final julia = harness.registry.byId('julia');
    final missing = unavailableCopy(mandelbrot);
    final sink = FractalRenderSnapshotSink();
    final boundaryKey = GlobalKey();
    FractalRenderer.clearShaderCacheForMemoryPressure();
    addTearDown(() {
      harness.dispose();
      FractalRenderer.clearShaderCacheForMemoryPressure();
    });

    controller.selectModule(mandelbrot);
    await tester.pumpWidget(harness.wrapScaffold(FractalRenderer(
      animationEnabled: false,
      boundaryKey: boundaryKey,
      renderSnapshotSink: sink,
    )));
    final l10n =
        AppLocalizations.of(tester.element(find.byType(FractalRenderer)))!;

    Future<void> expectReady(FractalModule module) async {
      await pumpUntil(tester, () => sink.snapshot?.module.id == module.id,
          'Ready(${module.id})');
      expect(find.text('Shader Error'), findsNothing);
      expect(find.text('Shader file not found. Please reinstall the app.'),
          findsNothing);
      expect(find.text('Show Details'), findsNothing);
      expect(find.text('Attempt 3/3'), findsNothing);
      expect(find.text(l10n.shaderErrorGoBack), findsNothing);
      expect(find.byKey(const Key('fractalTestSurface')), findsNothing);
      expect(sink.snapshot!.module.shaderAsset, module.shaderAsset);
      final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final painter =
          paints.map((w) => w.painter).whereType<FractalCanvas>().single;
      expect(painter.module.id, module.id);
      expect(painter.module.shaderAsset, module.shaderAsset);
      final boundary = boundaryKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 0.5);
        try {
          return await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        } finally {
          image.dispose();
        }
      });
      expect(bytes, isNotNull);
      final rgba =
          bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      final colors = <int>{};
      var visibleColoredPixels = 0;
      for (var i = 0; i < rgba.length; i += 4) {
        colors.add((rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2]);
        if (rgba[i + 3] > 0 && (rgba[i] + rgba[i + 1] + rgba[i + 2]) > 0) {
          visibleColoredPixels++;
        }
      }
      expect(colors.length, greaterThan(16), reason: 'Nonuniform real fractal');
      expect(visibleColoredPixels, greaterThan(rgba.length ~/ 400),
          reason: 'Nonblank real boundary readback');
      expect(tester.takeException(), isNull);
    }

    Future<void> expectFailure() async {
      expect(
          await controller.loadState(
            module: missing,
            params: Map<String, Object>.from(controller.params),
            view: controller.view,
          ),
          isTrue);
      await tester.pump();
      await pumpUntil(
          tester,
          () => find.text('Attempt 3/3').evaluate().isNotEmpty,
          'terminal missing-asset failure');
      expect(find.text('Shader Error'), findsOneWidget);
      expect(find.text('Shader file not found. Please reinstall the app.'),
          findsOneWidget);
      expect(find.text(l10n.shaderErrorGoBack), findsOneWidget);
      expect(find.text('Show Details'), findsOneWidget);
      expect(sink.snapshot, isNull);
      expect(tester.takeException(), isNull);
    }

    await expectReady(mandelbrot); // B is now cached.
    await expectFailure();
    controller.selectModule(mandelbrot); // No cache clear and no manual Retry.
    await tester.pump();
    await expectReady(mandelbrot);
    await expectFailure();
    controller.selectModule(julia); // C has never been loaded in this process.
    await tester.pump();
    await expectReady(julia);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
