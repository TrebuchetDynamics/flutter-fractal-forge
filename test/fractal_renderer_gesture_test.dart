import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('FractalRenderer drag updates pan; pinch updates zoom', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialPan = controller.view.pan.clone();
    final initialZoom = controller.view.zoom;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: FractalRenderer(),
            ),
          ),
        ),
      ),
    );

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
    await tester.pump();

    expect(controller.view.zoom, isNot(equals(initialZoom)));
  });
}
