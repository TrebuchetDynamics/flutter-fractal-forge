import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget(FractalController controller, {
    VoidCallback? onOpenControls,
    VoidCallback? onOpenPresets,
    VoidCallback? onOpenExport,
  }) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: FractalRenderer(
              onOpenControls: onOpenControls,
              onOpenPresets: onOpenPresets,
              onOpenExport: onOpenExport,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('FractalRenderer drag updates pan; pinch updates zoom', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialPan = controller.view.pan.clone();
    final initialZoom = controller.view.zoom;

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);

    // Drag gesture should update pan.
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, isNot(equals(initialPan.x)));
    expect(controller.view.pan.y, isNot(equals(initialPan.y)));

    // Pinch gesture should update zoom.
    // Use two touch pointers moving apart.
    final center = tester.getCenter(find.byType(FractalRenderer));
    final g1 = await tester.createGesture();
    final g2 = await tester.createGesture();

    await g1.down(center + const Offset(-40, 0));
    await g2.down(center + const Offset(40, 0));
    await tester.pump();

    await g1.moveTo(center + const Offset(-70, 0));
    await g2.moveTo(center + const Offset(70, 0));
    await tester.pump();

    await g1.up();
    await g2.up();
    // Wait for double-tap timeout and momentum animations to complete
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(controller.view.zoom, isNot(equals(initialZoom)));
  });

  testWidgets('Double-tap resets view to default', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // First, modify the view by panning
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    // Store modified values
    final modifiedPan = controller.view.pan.clone();
    expect(modifiedPan.x, isNot(0.0));

    // Double-tap to reset
    await tester.tap(find.byType(FractalRenderer));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    // Verify view was reset
    expect(controller.view.pan.x, equals(0.0));
    expect(controller.view.pan.y, equals(0.0));
    expect(controller.view.zoom, equals(1.0));
  });

  testWidgets('Long-press shows context menu', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Long-press to show context menu
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    // Verify context menu appears with expected items
    expect(find.text('Reset View'), findsOneWidget);
    expect(find.text('Open Controls'), findsOneWidget);
    expect(find.text('Open Presets'), findsOneWidget);
    expect(find.text('Randomize'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('Context menu reset option resets view', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Modify the view
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, isNot(0.0));

    // Long-press and select reset
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset View'));
    await tester.pumpAndSettle();

    // Verify view was reset
    expect(controller.view.pan.x, equals(0.0));
    expect(controller.view.pan.y, equals(0.0));
  });

  testWidgets('Context menu randomize option randomizes params', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialParams = Map<String, Object>.from(controller.params);

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Long-press and select randomize
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Randomize'));
    await tester.pumpAndSettle();

    // Verify at least some params changed (randomization should affect something)
    bool anyChanged = false;
    for (final key in controller.params.keys) {
      if (controller.params[key] != initialParams[key]) {
        anyChanged = true;
        break;
      }
    }
    // Note: There's a small chance randomization produces the same values
    // but this is statistically unlikely with multiple parameters
    expect(anyChanged || controller.params.isEmpty, isTrue);
  });

  testWidgets('Context menu callbacks are invoked', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    bool controlsOpened = false;
    bool presetsOpened = false;
    bool exportOpened = false;

    await tester.pumpWidget(buildTestWidget(
      controller,
      onOpenControls: () => controlsOpened = true,
      onOpenPresets: () => presetsOpened = true,
      onOpenExport: () => exportOpened = true,
    ));
    await tester.pumpAndSettle();

    // Test controls callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Controls'));
    await tester.pumpAndSettle();
    expect(controlsOpened, isTrue);

    // Test presets callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Presets'));
    await tester.pumpAndSettle();
    expect(presetsOpened, isTrue);

    // Test export callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(exportOpened, isTrue);
  });

  testWidgets('Gestures disabled prevents all interactions', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialPan = controller.view.pan.clone();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: FractalRenderer(gesturesEnabled: false),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try to drag - should have no effect
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, equals(initialPan.x));
    expect(controller.view.pan.y, equals(initialPan.y));
  });

  testWidgets('Pinch-to-zoom is smooth with interpolation', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final zoomValues = <double>[];

    controller.addListener(() {
      zoomValues.add(controller.view.zoom);
    });

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Perform a gradual pinch
    final center = tester.getCenter(find.byType(FractalRenderer));
    final g1 = await tester.createGesture();
    final g2 = await tester.createGesture();

    await g1.down(center + const Offset(-30, 0));
    await g2.down(center + const Offset(30, 0));
    await tester.pump();

    // Move gradually
    for (int i = 1; i <= 5; i++) {
      await g1.moveTo(center + Offset(-30.0 - i * 8, 0));
      await g2.moveTo(center + Offset(30.0 + i * 8, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }

    await g1.up();
    await g2.up();
    await tester.pump();

    // Verify zoom changed progressively (smooth)
    expect(zoomValues.length, greaterThan(1));
    // Each zoom value should be reasonably close to the previous (no huge jumps)
    for (int i = 1; i < zoomValues.length; i++) {
      final ratio = zoomValues[i] / zoomValues[i - 1];
      expect(ratio, inInclusiveRange(0.5, 2.0)); // No crazy jumps
    }
  });
}
