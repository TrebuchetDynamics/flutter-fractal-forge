import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    required void Function(ExportOptions, ExportAction) onExport,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExportOptionsSheet(
            initialOptions: const ExportOptions(),
            fractalType: 'mandelbrot',
            onExport: onExport,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('save action triggers saveOnly export action', (tester) async {
    ExportAction? action;

    await pumpSheet(
      tester,
      onExport: (_, a) => action = a,
    );

    await tester.tap(find.byIcon(Icons.save_alt_rounded));
    await tester.pumpAndSettle();

    expect(action, ExportAction.saveOnly);
  });

  testWidgets('share action triggers saveAndShare export action',
      (tester) async {
    ExportAction? action;

    await pumpSheet(
      tester,
      onExport: (_, a) => action = a,
    );

    await tester.tap(find.byIcon(Icons.share_rounded));
    await tester.pumpAndSettle();

    expect(action, ExportAction.saveAndShare);
  });
}
