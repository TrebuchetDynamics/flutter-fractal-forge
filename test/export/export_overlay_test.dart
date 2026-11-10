import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/viewer/export/viewer_export_overlay.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  testWidgets('short large-text progress overlay keeps cancel reachable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var cancelled = 0;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(3),
          viewPadding: const EdgeInsets.only(bottom: 24),
        ),
        child: child!,
      ),
      home: Scaffold(
          body: Builder(
              builder: (context) => ExportOverlay(
                    progress: 0.5,
                    l10n: AppLocalizations.of(context)!,
                    onCancel: () => cancelled++,
                  ))),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(SingleChildScrollView)).bottom,
        lessThanOrEqualTo(216));
    final cancel = find.byKey(const ValueKey('cancelActiveExportButton'));
    await tester.ensureVisible(cancel);
    await tester.pumpAndSettle();
    expect(tester.getRect(cancel).bottom, lessThanOrEqualTo(216));
    await tester.tap(cancel);
    expect(cancelled, 1);
  });
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
