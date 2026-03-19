import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<ExportSheetSubmission?> pumpSheetAndSubmit(
    WidgetTester tester, {
    required Finder submitButton,
    ExportOptions initialOptions = const ExportOptions(),
  }) async {
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
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    return submission;
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
