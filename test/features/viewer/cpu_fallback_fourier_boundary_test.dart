import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/rendering/cpu_fallback_pane.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Fourier spatial boundary excludes CPU fallback status badge',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    final spatialBoundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FractalController>.value(
          value: controller,
          child: SizedBox(
            width: 320,
            height: 320,
            child: CpuFallbackPane(boundaryKey: spatialBoundaryKey),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Stable renderer active'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(spatialBoundaryKey),
        matching: find.text('Stable renderer active'),
      ),
      findsNothing,
      reason: 'viewer chrome must not contaminate Fourier source pixels',
    );
  });
}
