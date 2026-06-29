import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/main.dart' as app;

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder moduleCards() {
    return find.byWidgetPredicate((w) {
      final k = w.key;
      if (k is! ValueKey) return false;
      final v = k.value;
      if (v is! String) return false;
      return v.startsWith('catalogModuleCard_') ||
          v.startsWith('catalogGridTile_');
    });
  }

  testWidgets('double-tap anchor + pan stability on emulator', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
      'renderer_backend_mode': 'auto',
    });

    await app.main();
    await pumpForAppBoot(tester);

    expect(moduleCards(), findsWidgets);

    final firstCard = moduleCards().first;
    await tester.ensureVisible(firstCard);
    await tester.tap(firstCard);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(FractalRenderer), findsWidgets);

    final viewerElement =
        tester.element(find.byType(FractalViewerScreen).first);
    final controller =
        Provider.of<FractalController>(viewerElement, listen: false);

    final initialZoom = controller.view.zoom;
    final initialPanX = controller.view.pan.x;
    final initialPanY = controller.view.pan.y;

    final renderer = find.byType(FractalRenderer).first;
    final rect = tester.getRect(renderer);
    // Use a viewport-safe point that avoids app bar overlap while staying in
    // the upper-left quadrant (so pan.x/pan.y both move negative on zoom-in).
    final tapPoint = Offset(
      rect.left + rect.width * 0.32,
      rect.top + rect.height * 0.38,
    );

    await tester.tapAt(tapPoint);
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tapAt(tapPoint);
    await pumpForUiTransition(
      tester,
      settle: const Duration(milliseconds: 350),
    );

    expect(controller.view.zoom, greaterThan(initialZoom));
    expect(controller.view.pan.x, lessThan(initialPanX));
    expect(controller.view.pan.y, lessThan(initialPanY));

    final beforeDragX = controller.view.pan.x;
    final beforeDragY = controller.view.pan.y;

    await tester.drag(renderer, const Offset(120, 0));
    await tester.pump(const Duration(milliseconds: 120));

    final afterDragX = controller.view.pan.x;
    final afterDragY = controller.view.pan.y;

    expect(afterDragX.isFinite, isTrue);
    expect(afterDragY.isFinite, isTrue);
    expect((afterDragX - beforeDragX).abs(), greaterThan(1e-6));
    // Horizontal drag should not explode vertical pan.
    expect((afterDragY - beforeDragY).abs(), lessThan(0.5));
  });
}
