import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/controls/widgets/number_wall_style_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/shared/widgets/app_bottom_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RGB dialog retains invalid edits and only applies valid colors',
      (tester) async {
    final changes = <Object>[];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: NumberWallColorControl(
        param: FractalParameter(
          id: 'color',
          label: (_) => 'Cell color',
          type: FractalParamType.integer,
          min: 0,
          max: 0xffffff,
          step: 1,
          defaultValue: 0x112233,
        ),
        value: 0x112233,
        onChanged: changes.add,
      )),
    ));
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);
    final input = find.byType(TextFormField);
    await tester.enterText(input, 'zzzzzz');
    expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'zzzzzz');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(find.byType(AppDialog), findsOneWidget);
    await tester.enterText(input, 'abcdef');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();
    expect(changes, [0xabcdef]);
    expect(find.byType(AppDialog), findsNothing);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    await tester.enterText(input, 'ffffff');
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(changes, [0xabcdef]);
    expect(find.byType(AppDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
