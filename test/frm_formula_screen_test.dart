import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/formulas/frm_formula_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Formula Lab shows its controls', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: FrmFormulaScreen()));
      await tester.pump();

      expect(find.text('Formula Lab'), findsOneWidget);
      expect(find.text('Render'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Mandelbrot'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Julia'), findsOneWidget);
    });
  });

  testWidgets('shows a parse error for an invalid formula', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: FrmFormulaScreen()));
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
