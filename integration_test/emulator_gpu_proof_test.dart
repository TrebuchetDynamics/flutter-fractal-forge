import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/renderer/render_validation.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart' as app;

class _ViewerEvidenceFrame {
  final RenderFrameStats stats;
  final String pngBase64;

  const _ViewerEvidenceFrame({required this.stats, required this.pngBase64});
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  Finder cardFinder(String catalogId) {
    final listCard = find.byKey(ValueKey('catalogModuleCard_$catalogId'));
    if (listCard.evaluate().isNotEmpty) return listCard;
    return find.byKey(ValueKey('catalogGridTile_$catalogId'));
  }

  Future<Finder> findCardByScrolling(
    WidgetTester tester,
    String catalogId,
  ) async {
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 18; i++) {
      final candidate = cardFinder(catalogId);
      if (candidate.evaluate().isNotEmpty) {
        return candidate;
      }
      await tester.drag(scrollable, const Offset(0, -320));
      await tester.pump(const Duration(milliseconds: 350));
    }
    fail('Catalog card not found after scrolling: $catalogId');
  }

  Future<_ViewerEvidenceFrame> waitForViewerReady(WidgetTester tester) async {
    // Wait until shader loading placeholder is gone.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(FractalLoadingIndicator).evaluate().isEmpty) {
        break;
      }
    }

    // Require renderer widget to be active and no loading indicator.
    expect(find.byType(FractalRenderer), findsWidgets,
        reason: 'Fractal renderer not present in viewer');
    expect(find.byType(FractalLoadingIndicator), findsNothing,
        reason: 'Viewer still in loading/placeholder state');

    // Let at least a few frames render and allow 2s health check to log.
    await tester.pump(const Duration(seconds: 4));

    final renderer = find.byType(FractalRenderer).first;
    final repaintBoundaryFinder = find
        .ancestor(of: renderer, matching: find.byType(RepaintBoundary))
        .first;
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(repaintBoundaryFinder);

    final ui.Image image = await boundary.toImage(pixelRatio: 0.15);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(byteData, isNotNull, reason: 'Failed to read renderer frame bytes');

    final frameBytes = byteData!.buffer.asUint8List();
    final stats = validateRenderFrame(
      frame: frameBytes,
      width: image.width,
      height: image.height,
    );
    final pngData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    expect(pngData, isNotNull,
        reason: 'Failed to encode rendered frame as PNG evidence');
    expect(stats.histogramSane, isTrue,
        reason: 'Frame histogram looks flat/invalid for rendered fractal');
    expect(stats.nonBlackRatio, greaterThan(0.01),
        reason: 'Frame non-black ratio too low for valid fractal render');

    return _ViewerEvidenceFrame(
      stats: stats,
      pngBase64: base64Encode(pngData!.buffer.asUint8List()),
    );
  }

  Future<void> captureFractal({
    required WidgetTester tester,
    required String catalogId,
    required String moduleId,
    required String screenshotName,
  }) async {
    final card = await findCardByScrolling(tester, catalogId);

    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Gate 1: viewer screen active.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget,
        reason: 'Viewer screen did not open for $catalogId');

    // Gate 2: selected module identity matches expected fractal.
    final viewerElement = tester.element(find.byType(FractalViewerScreen));
    final controller =
        Provider.of<FractalController>(viewerElement, listen: false);
    expect(controller.module.id, moduleId,
        reason:
            'Viewer module id mismatch for $catalogId (expected $moduleId)');

    // Gate 3: frame rendered (not loading/placeholder).
    final evidenceFrame = await waitForViewerReady(tester);

    final now = DateTime.now();
    final tsMs = now.millisecondsSinceEpoch;
    debugPrint(
      '[evidence] capture_ready fractal=$moduleId catalog=$catalogId screenshot=$screenshotName tsMs=$tsMs tsIso=${now.toIso8601String()} viewerActive=true moduleVerified=true frameReady=true frameNonBlackRatio=${evidenceFrame.stats.nonBlackRatio.toStringAsFixed(4)} frameCenterNonBlack=${evidenceFrame.stats.centerNonBlack} frameHistogramSane=${evidenceFrame.stats.histogramSane}',
    );
    debugPrint(
      '[evidence] frame_png fractal=$moduleId b64=${evidenceFrame.pngBase64}',
    );

    // Give host-side proof script a deterministic capture window after gate passes.
    await tester.pump(const Duration(milliseconds: 1600));

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('capture auditable GPU evidence on emulator for 3 fractals',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
      // Explicitly run policy in auto mode.
      'renderer_backend_mode': 'auto',
    });

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await captureFractal(
      tester: tester,
      catalogId: 'core.mandelbrot',
      moduleId: 'mandelbrot',
      screenshotName: 'gpu_proof_mandelbrot',
    );

    await captureFractal(
      tester: tester,
      catalogId: 'core.burning_ship',
      moduleId: 'burning_ship',
      screenshotName: 'gpu_proof_burning_ship',
    );

    await captureFractal(
      tester: tester,
      catalogId: 'core.tricorn',
      moduleId: 'tricorn',
      screenshotName: 'gpu_proof_tricorn',
    );
  }, timeout: const Timeout(Duration(minutes: 8)));
}
