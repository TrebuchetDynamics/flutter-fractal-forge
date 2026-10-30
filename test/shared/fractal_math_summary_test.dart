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

  for (final locale in const [Locale('en'), Locale('es')]) {
    testWidgets(
        'HUD distinguishes starting name from current edited Julia formula (${locale.languageCode})',
        (tester) async {
      harness.controller
          .selectModule(harness.registry.byId('f0166_chebyshev_julia'));
      await tester.pumpWidget(harness.wrapScaffold(
        const FractalControlsHud(),
        locale: locale,
      ));
      await tester.pumpAndSettle();
      final startingName = locale.languageCode == 'es'
          ? 'Configuración inicial: Chebyshev Julia'
          : 'Starting configuration: Chebyshev Julia';
      expect(find.text(startingName), findsNothing);
      final qualification = locale.languageCode == 'es'
          ? 'Recurrencia revisada en código; configuración inicial con nombre'
          : 'Source-reviewed recurrence; named starting configuration';
      final family = locale.languageCode == 'es'
          ? 'Dinámica compleja'
          : 'Complex dynamics';
      expect(find.text(qualification), findsOneWidget);
      expect(find.textContaining(family), findsNothing);
      final formula = find.byKey(const Key('currentMathematicalFormula'));
      expect(formula, findsOneWidget);
      final formulaText = tester.widget<Text>(formula);
      expect(formulaText.data, contains('(-2.0, 0.0)'));
      expect(formulaText.maxLines, 2);
      expect(formulaText.overflow, TextOverflow.ellipsis);
      harness.controller.updateParam('juliaCReal', 0.2);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(formula).data, contains('(0.2, 0.0)'));
      expect(find.text(startingName), findsNothing);

      final details = find.text(locale.languageCode == 'es'
          ? 'Detalles de la fórmula'
          : 'Formula details');
      await tester.ensureVisible(details);
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(find.text(startingName), findsOneWidget);
      expect(find.text(qualification), findsOneWidget);
      expect(find.textContaining(family), findsOneWidget);
      expect(formula, findsOneWidget);
      expect(tester.widget<Text>(formula).maxLines, isNull);
      expect(tester.widget<Text>(formula).data, contains('(0.2, 0.0)'));
    });
  }

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

  for (final locale in const [Locale('en'), Locale('es')]) {
    testWidgets(
        'compact Fibonacci legend fits the caption and keeps full semantics (${locale.languageCode})',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(harness.wrapScaffold(
        Center(
          child: SizedBox(
            width: 201,
            height: 106,
            child: Align(
              alignment: Alignment.topLeft,
              child: FractalMathSummary(
                module: harness.registry.byId('fibonacci_complex_julia'),
                compact: true,
              ),
            ),
          ),
        ),
        locale: locale,
      ));
      await tester.pumpAndSettle();
      final legend = find.byKey(const Key('fibonacciComplexLegend'));
      final text = tester.widget<Text>(legend).data!;
      expect(text.length, greaterThan(400));
      expect(tester.getSize(legend).height, lessThanOrEqualTo(42));
      expect(tester.getSemantics(legend).label, text);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sine sphere summary exposes edited finite formula in EN and ES',
      (tester) async {
    for (final language in ['en', 'es']) {
      await tester.pumpWidget(harness.wrapScaffold(
        FractalMathSummary(
          module: harness.registry.byId('recursive_sine_sphere'),
          params: const {
            'depth': 2,
            'strength': 0.5,
            'radius': 1.25,
            'phase': 0.4,
            'animate': true,
          },
        ),
        locale: Locale(language),
      ));
      await tester.pumpAndSettle();
      final formula = tester
          .widget<Text>(find.byKey(const Key('currentMathematicalFormula')))
          .data!;
      expect(formula, contains('q(n+1)=q(n)+a*2^-n*sin(2^n*C(q(n))+phase(t))'));
      expect(formula, contains('C(x,y,z)=(y,z,x)'));
      expect(formula, contains('|q(N)|-R=0; N=2, a=0.5, R=1.25, phi=0.4'));
      expect(formula, contains('phase(t)=phi+0.0002*t'));
      expect(find.textContaining('Íñigo Quílez'), findsOneWidget);
      expect(
          find.text(language == 'es'
              ? 'Esfera finita deformada por seno; no es un SDF ni un fractal infinito'
              : 'Finite sine-warped sphere; not an SDF or an infinite fractal'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    }
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
