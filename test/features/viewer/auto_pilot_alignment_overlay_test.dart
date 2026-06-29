import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/overlays/auto_pilot_alignment_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows crosshair only while auto-pilot yields to user touch',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    final service = AutoExploreService(controller: controller);
    addTearDown(service.dispose);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AutoPilotAlignmentOverlay(service: service),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('autoPilotAlignmentCrosshair')),
        findsNothing);

    service.start();
    service.onUserInteractionStart();
    await tester.pump();

    expect(find.byKey(const ValueKey('autoPilotAlignmentCrosshair')),
        findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Auto-pilot paused. Align zoom with the center crosshair.',
      ),
      findsOneWidget,
    );

    service.onUserInteractionEnd();
    await tester.pump();

    expect(find.byKey(const ValueKey('autoPilotAlignmentCrosshair')),
        findsNothing);

    service.stop();
    await tester.pump();
  });
}
