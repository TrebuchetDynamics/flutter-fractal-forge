import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore_service.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/overlays/auto_pilot_alignment_overlay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  testWidgets('announces paused alignment in Spanish', (tester) async {
    final controller = FractalController(ModuleRegistry());
    final service = AutoExploreService(controller: controller);
    addTearDown(service.dispose);
    addTearDown(controller.dispose);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AutoPilotAlignmentOverlay(service: service),
    ));
    service.start();
    service.onUserInteractionStart();
    await tester.pump();

    expect(
      find.bySemanticsLabel(
        'Piloto automático en pausa. Alinea el zoom con la retícula central.',
      ),
      findsOneWidget,
    );
    service.stop();
    await tester.pump();
    semantics.dispose();
  });

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
