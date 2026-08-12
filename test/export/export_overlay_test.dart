import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  testWidgets('export overlay exposes cancellation while work is active',
      (tester) async {
    var cancelled = false;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        return ExportOverlay(
          progress: 0.5,
          l10n: AppLocalizations.of(context)!,
          onCancel: () => cancelled = true,
        );
      }),
    ));

    await tester.tap(find.byKey(const ValueKey('cancelActiveExportButton')));
    expect(cancelled, isTrue);
    expect(find.text('50%'), findsOneWidget);
  });
}
