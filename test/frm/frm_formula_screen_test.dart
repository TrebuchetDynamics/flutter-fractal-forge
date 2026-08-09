import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/formulas/frm_formula_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The screen reads AppLocalizations, so the delegates are required. Supplying
/// the app's theme as well means these render what the app renders rather than
/// the default light Material one.
Widget _app({Locale locale = const Locale('en')}) => MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FrmFormulaScreen(),
    );

void main() {
  testWidgets('Formula Lab shows its controls', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await tester.pump();

      expect(find.text('Formula Lab'), findsOneWidget);
      expect(find.text('Render'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Mandelbrot'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Julia'), findsOneWidget);
    });
  });

  testWidgets('keeps the valid preview when evaluation fails', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await tester.pump();

      await tester.ensureVisible(find.text('Render'));
      await tester.tap(find.text('Render'));
      for (var attempt = 0;
          attempt < 100 && find.byType(RawImage).evaluate().isEmpty;
          attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
      expect(find.byType(RawImage), findsOneWidget);

      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(
        find.byType(TextField),
        'Broken {\n  z=unknown\n:\n  z=z*z\n}\n',
      );
      await tester.ensureVisible(find.text('Render'));
      await tester.tap(find.text('Render'));
      for (var attempt = 0;
          attempt < 100 &&
              find.textContaining('Unknown var: unknown').evaluate().isEmpty;
          attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }

      expect(find.textContaining('Unknown var: unknown'), findsOneWidget);
      expect(find.byType(RawImage), findsOneWidget);
    });
  });

  testWidgets('shows a parse error for an invalid formula', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await tester.pump();

      // Invalid source: the parse runs on the main thread (before the isolate
      // render), so the error surfaces deterministically.
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'not a valid formula');
      await tester.ensureVisible(find.text('Render'));
      await tester.tap(find.text('Render'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Expected'), findsOneWidget);
    });
  });
}
