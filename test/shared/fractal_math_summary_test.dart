import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  late FractalControllerWidgetHarness harness;
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    harness = FractalControllerWidgetHarness();
  });
  tearDown(() => harness.dispose());

  testWidgets(
      'HUD distinguishes starting name from current edited Julia formula',
      (tester) async {
    harness.controller
        .selectModule(harness.registry.byId('f0166_chebyshev_julia'));
    await tester.pumpWidget(harness.wrapScaffold(const FractalControlsHud()));
    await tester.pumpAndSettle();
    expect(
        find.text('Starting configuration: Chebyshev Julia'), findsOneWidget);
    final formula = find.byKey(const Key('currentMathematicalFormula'));
    expect(tester.widget<Text>(formula).data, contains('(-2.0, 0.0)'));
    harness.controller.updateParam('juliaCReal', 0.2);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(formula).data, contains('(0.2, 0.0)'));
    expect(
        find.text('Starting configuration: Chebyshev Julia'), findsOneWidget);
  });

  testWidgets('Spanish summary localizes family and uncertainty qualification',
      (tester) async {
    await tester.pumpWidget(harness.wrapScaffold(
      FractalMathSummary(module: harness.registry.byId('ammann_beenker')),
      locale: const Locale('es'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Regla / fórmula actual'), findsOneWidget);
    expect(
        find.text('Inspirado en teselados; sustitución exacta no verificada'),
        findsOneWidget);
    expect(find.textContaining('Teselados, sustituciones y sistemas L'),
        findsOneWidget);
    expect(
        find.textContaining(
            'este renderizador no se ha revisado matemáticamente'),
        findsOneWidget);
  });

  testWidgets('cellular rule view does not claim simulated evolution',
      (tester) async {
    await tester.pumpWidget(harness.wrapScaffold(
      FractalMathSummary(module: harness.registry.byId('life_like_b008_s000')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Rule-inspired procedural visualization'), findsOneWidget);
    expect(find.textContaining('Life-like B3/S;'), findsOneWidget);
    expect(
        find.textContaining('Procedural rule visualization'), findsOneWidget);
  });
}
