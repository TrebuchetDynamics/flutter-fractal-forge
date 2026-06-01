import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _SheetHarness {
  ExportSheetSubmission? submission;
}

void main() {
  Future<_SheetHarness> pumpSheet(
    WidgetTester tester, {
    ExportOptions initialOptions = const ExportOptions(),
  }) async {
    final harness = _SheetHarness();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  harness.submission = await ExportOptionsSheet.show(
                    context,
                    initialOptions: initialOptions,
                    fractalType: 'mandelbrot',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return harness;
  }

  Future<ExportSheetSubmission?> pumpSheetAndSubmit(
    WidgetTester tester, {
    required Finder submitButton,
    ExportOptions initialOptions = const ExportOptions(),
  }) async {
    final harness = await pumpSheet(
      tester,
      initialOptions: initialOptions,
    );
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    return harness.submission;
  }

  testWidgets('save action triggers saveOnly export action', (tester) async {
    final submission = await pumpSheetAndSubmit(
      tester,
      submitButton: find.byKey(const ValueKey('exportSaveButton')),
    );

    expect(submission?.action, ExportAction.saveOnly);
  });

  testWidgets('share action triggers saveAndShare export action',
      (tester) async {
    final submission = await pumpSheetAndSubmit(
      tester,
      submitButton: find.byKey(const ValueKey('exportShareButton')),
    );

    expect(submission?.action, ExportAction.saveAndShare);
  });

  testWidgets('custom resolution export includes default dimensions',
      (tester) async {
    final submission = await pumpSheetAndSubmit(
      tester,
      submitButton: find.byKey(const ValueKey('exportSaveButton')),
      initialOptions: const ExportOptions(resolution: ExportResolution.custom),
    );

    expect(submission, isNotNull);
    expect(submission!.options.resolution, ExportResolution.custom);
    expect(submission.options.customWidth, 1920);
    expect(submission.options.customHeight, 1080);
  });

  testWidgets('custom fields remain export source after preset round-trip',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = await pumpSheet(
      tester,
      initialOptions: const ExportOptions(
        resolution: ExportResolution.custom,
        customWidth: 333,
        customHeight: 444,
      ),
    );

    await tester.tap(find.text('Customize').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Web'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(ExportResolution.custom.displayName));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '333'), findsOneWidget);
    expect(find.widgetWithText(TextField, '444'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
    await tester.pumpAndSettle();

    expect(harness.submission, isNotNull);
    expect(harness.submission!.options.resolution, ExportResolution.custom);
    expect(harness.submission!.options.customWidth, 333);
    expect(harness.submission!.options.customHeight, 444);
  });

  testWidgets('sheet helper returns null when dismissed', (tester) async {
    ExportSheetSubmission? submission;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  submission = await ExportOptionsSheet.show(
                    context,
                    initialOptions: const ExportOptions(),
                    fractalType: 'mandelbrot',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(submission, isNull);
  });
}
