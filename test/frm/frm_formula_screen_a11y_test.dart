import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/formulas/frm_formula_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../a11y/semantics/interactive_name_audit.dart';
import '../helpers/overflow_guard.dart';

Future<void> _pumpLab(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
  Locale locale = const Locale('en'),
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const FrmFormulaScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('FrmFormulaScreen accessibility', () {
    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpLab(tester);
      final root = semanticsRoot(tester);

      expect(operableControlNames(root), isNotEmpty,
          reason: 'nothing rendered, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      handle.dispose();
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpLab(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
      ]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await expectNoOverflow(
            () => _pumpLab(tester, textScale: scale, size: size),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('copy localizes', (tester) async {
      await _pumpLab(tester, locale: const Locale('es'));

      expect(find.text('Laboratorio de fórmulas'), findsOneWidget);
      expect(find.text('Renderizar'), findsOneWidget);
      expect(find.text('Fórmula FRM'), findsOneWidget);
      expect(find.text('Toca Renderizar para previsualizar'), findsOneWidget);

      for (final english in const [
        'Formula Lab',
        'Render',
        'FRM formula',
        'Tap Render to preview',
      ]) {
        expect(find.text(english), findsNothing, reason: english);
      }

      // The example names are FRM source identifiers — they appear inside the
      // formula text itself — so they stay untranslated on purpose.
      expect(find.widgetWithText(ActionChip, 'Mandelbrot'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Julia'), findsOneWidget);
    });
  });
}
