import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/fourier/lab/fractal_uncertainty_lab_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lab reports a finite converged Cantor experiment',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FractalUncertaintyLabScreen(),
      ),
    );

    expect(find.text('Finite numerical experiment—not a mathematical proof.'),
        findsOneWidget);
    final runButton = find.byKey(const ValueKey('runUncertaintyExperiment'));
    await tester.scrollUntilVisible(
      runButton,
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(runButton);
    await tester.pump();
    for (var attempt = 0;
        attempt < 100 &&
            find.textContaining('Estimated restricted').evaluate().isEmpty;
        attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();

    expect(find.textContaining('Estimated restricted Fourier norm'),
        findsOneWidget);
    expect(find.textContaining('Estimated minimum leakage'), findsOneWidget);
    expect(find.textContaining('Convergence residual'), findsOneWidget);
    expect(find.textContaining('Hilbert–Schmidt bound'), findsOneWidget);
  });

  testWidgets('orthogonal-line preset demonstrates the known obstruction',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FractalUncertaintyLabScreen(
          initialPreset: FractalUncertaintyPreset.orthogonalLines,
        ),
      ),
    );

    expect(find.text('Known orthogonal-line obstruction'), findsOneWidget);
    final runButton = find.byKey(const ValueKey('runUncertaintyExperiment'));
    await tester.scrollUntilVisible(
      runButton,
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(runButton);
    await tester.pump();
    for (var attempt = 0;
        attempt < 100 && find.textContaining('100.0%').evaluate().isEmpty;
        attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();

    expect(find.textContaining('Estimated maximum retained energy: 100.0%'),
        findsOneWidget);
    expect(
        find.textContaining('Estimated minimum leakage: 0.0%'), findsOneWidget);
  });

  testWidgets('lab copy localizes to Spanish', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FractalUncertaintyLabScreen(),
      ),
    );

    expect(find.text('Laboratorio de incertidumbre fractal'), findsOneWidget);
    expect(
      find.text('Finite numerical experiment—not a mathematical proof.'),
      findsOneWidget,
    );
    expect(find.text('Profundidad de recursión: 2'), findsOneWidget);
  });

  testWidgets('popping the lab cancels its owned estimate isolate',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FractalUncertaintyLabScreen(),
    ));

    final runButton = find.byKey(const ValueKey('runUncertaintyExperiment'));
    await tester.scrollUntilVisible(
      runButton,
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(runButton);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
