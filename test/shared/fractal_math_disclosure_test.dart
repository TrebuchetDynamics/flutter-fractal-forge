import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/fractal_math_summary.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  late FractalControllerWidgetHarness harness;
  setUp(() => harness = FractalControllerWidgetHarness());
  tearDown(() => harness.dispose());

  Widget wrap(Widget child, String language) => harness.wrapScaffold(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: SingleChildScrollView(
            child: SizedBox(width: 320, child: child),
          ),
        ),
        locale: Locale(language),
        theme: AppTheme.dark,
      );

  final formulaFinder = find.byKey(const Key('currentMathematicalFormula'));

  for (final language in ['en', 'es']) {
    final spanish = language == 'es';
    final details = spanish ? 'Detalles de la fórmula' : 'Formula details';

    testWidgets(
        'unreviewed warning stays visible once before details ($language)',
        (tester) async {
      final base = harness.registry.byId('julia');
      final unknown = FractalModule(
        id: 'unreviewed_test',
        displayName: (_) => 'Unreviewed test',
        dimension: FractalDimension.twoD,
        shaderAsset: 'shaders/unreviewed_test.frag',
        parameters: base.parameters,
        defaultPreset: base.defaultPreset,
        builtInPresets: base.builtInPresets,
        setUniforms: base.setUniforms,
      );
      final warning = spanish
          ? 'Fórmula no verificada: este renderizador no se ha revisado matemáticamente'
          : 'Unverified formula: this renderer has not been mathematically reviewed';
      final family = spanish
          ? 'Sin clasificar · No verificado · Vista 2D · No verificado'
          : 'Unclassified · Unverified · 2D view · Unverified';
      final qualification =
          spanish ? 'Identidad no verificada' : 'Unverified identity';
      final starting =
          '${spanish ? 'Configuración inicial' : 'Starting configuration'}: Unreviewed test';
      await tester.pumpWidget(wrap(
        FractalMathSummary(module: unknown, collapsible: true),
        language,
      ));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(formulaFinder).data, warning);
      expect(find.text(warning), findsOneWidget);
      expect(tester.widget<Text>(formulaFinder).maxLines, isNull);
      expect(tester.widget<Text>(formulaFinder).overflow,
          isNot(TextOverflow.ellipsis));
      expect(find.text(starting), findsNothing);
      expect(find.text(family), findsNothing);
      expect(find.text(qualification), findsNothing);
      expect(find.text(details), findsOneWidget);

      await tester.tap(find.text(details));
      await tester.pumpAndSettle();
      expect(find.text(starting), findsOneWidget);
      expect(find.text(family), findsOneWidget);
      expect(find.text(qualification), findsOneWidget);
      expect(find.text(warning), findsOneWidget);
      await tester.tap(find.text(details));
      await tester.pumpAndSettle();
      expect(find.text(family), findsNothing);
      expect(find.text(qualification), findsNothing);
      expect(find.text(warning), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'expanded details preserve qualification and relationship ($language)',
        (tester) async {
      await tester.pumpWidget(wrap(
        FractalMathSummary(
          module: harness.registry.byId('ammann_beenker'),
          collapsible: true,
        ),
        language,
      ));
      await tester.pumpAndSettle();
      final qualification = spanish
          ? 'Inspirado en teselados; sustitución exacta no verificada'
          : 'Tiling-inspired; exact substitution tiling unverified';
      final relationship = spanish
          ? 'Teselados aperiódicos relacionados; no son alias'
          : 'Related aperiodic tilings; not aliases';
      final family = spanish
          ? 'Teselados, sustituciones y sistemas L · No verificado · Vista 2D · No verificado'
          : 'Tilings, substitutions and L-systems · Unverified · 2D view · Unverified';
      expect(find.text(qualification), findsNothing);
      expect(find.text(relationship), findsNothing);
      await tester.tap(find.text(details));
      await tester.pumpAndSettle();
      expect(find.text(qualification), findsOneWidget);
      expect(find.text(relationship), findsOneWidget);
      expect(find.text(family), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'current Julia formula follows live edits while collapsed and open ($language)',
        (tester) async {
      harness.controller
          .selectModule(harness.registry.byId('f0166_chebyshev_julia'));
      await tester.pumpWidget(wrap(
        ListenableBuilder(
          listenable: harness.controller,
          builder: (context, _) => FractalMathSummary(
            module: harness.controller.module,
            params: harness.controller.params,
            collapsible: true,
          ),
        ),
        language,
      ));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(formulaFinder).data,
          'z(n+1) = z(n)^2 + c; c = (-2.0, 0.0); z(0) = pixel');
      harness.controller.updateParam('juliaCReal', 0.2);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(formulaFinder).data,
          'z(n+1) = z(n)^2 + c; c = (0.2, 0.0); z(0) = pixel');
      await tester.tap(find.text(details));
      await tester.pumpAndSettle();
      harness.controller.updateParam('juliaCImag', 0.3);
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(formulaFinder).data,
          'z(n+1) = z(n)^2 + c; c = (0.2, 0.3); z(0) = pixel');
      expect(
          find.text(spanish
              ? 'Recurrencia revisada en código; configuración inicial con nombre'
              : 'Source-reviewed recurrence; named starting configuration'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'long source formula remains complete through disclosure ($language)',
        (tester) async {
      await tester.pumpWidget(wrap(
        FractalMathSummary(
          module: harness.registry.byId('recursive_sine_sphere'),
          params: const {
            'depth': 2,
            'strength': 0.5,
            'radius': 1.25,
            'phase': 0.4,
            'animate': true
          },
          collapsible: true,
        ),
        language,
      ));
      await tester.pumpAndSettle();
      const formula =
          'C(x,y,z)=(y,z,x); q(0)=p; q(n+1)=q(n)+a*2^-n*sin(2^n*C(q(n))+phase(t)), 0<=n<N; |q(N)|-R=0; N=2, a=0.5, R=1.25, phi=0.4; phase(t)=phi+0.0002*t';
      expect(tester.widget<Text>(formulaFinder).data, formula);
      expect(tester.widget<Text>(formulaFinder).maxLines, isNull);
      await tester.ensureVisible(find.text(details));
      await tester.tap(find.text(details));
      await tester.pumpAndSettle();
      expect(find.text(formula), findsOneWidget);
      expect(
          find.text(spanish
              ? 'Esfera finita deformada por seno; no es un SDF ni un fractal infinito'
              : 'Finite sine-warped sphere; not an SDF or an infinite fractal'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Fibonacci keeps the full existing legend and caveats ($language)',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(wrap(
        FractalMathSummary(
          module: harness.registry.byId('fibonacci_complex_julia'),
          collapsible: true,
        ),
        language,
      ));
      await tester.pumpAndSettle();
      final legendFinder = find.byKey(const Key('fibonacciComplexLegend'));
      final legend = tester.widget<Text>(legendFinder);
      expect(formulaFinder, findsOneWidget);
      expect(
          legend.data,
          contains(spanish
              ? 'Oscuro: sin escape en N, no demuestra acotación.'
              : 'Dark: not escaped within N, not proven bounded.'));
      expect(legend.data, contains('F19 = 4181 = 37 × 113'));
      expect(
          legend.data,
          AppLocalizations.of(tester.element(legendFinder))!
              .fibonacciComplexLegend);
      expect(legend.maxLines, isNull);
      expect(legend.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.getSemantics(legendFinder).label, legend.data);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('default and compact summaries do not gain disclosure',
      (tester) async {
    for (final compact in [false, true]) {
      await tester.pumpWidget(wrap(
          FractalMathSummary(
            module: harness.registry.byId('julia'),
            compact: compact,
            collapsible: compact,
          ),
          'en'));
      await tester.pumpAndSettle();
      expect(find.byType(ExpansionTile), findsNothing);
      expect(
          find.text('Source-reviewed recurrence; named starting configuration'),
          findsOneWidget);
      if (compact) {
        expect(find.textContaining('Starting configuration:'), findsNothing);
      } else {
        expect(find.textContaining('Starting configuration:'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });
}
