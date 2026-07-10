import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/features/export/export_actions.dart';
import 'package:flutter_fractals/features/export/export_options_sheet.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _SheetHarness {
  ExportSheetSubmission? submission;
}

void main() {
  test('ExportActionAvailability matches platform capabilities', () {
    expect(ExportActionAvailability.canSaveAndShare(isWeb: false), isTrue);
    expect(ExportActionAvailability.canSaveAndShare(isWeb: true), isFalse);
    expect(
      ExportActionAvailability.canSetWallpaper(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      ExportActionAvailability.canSetWallpaper(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    for (final platform in [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      expect(
        ExportActionAvailability.canSetWallpaper(
          isWeb: false,
          platform: platform,
        ),
        isFalse,
      );
    }
    expect(
      ExportActionAvailability.canSetWallpaper(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });

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

  testWidgets('shows explicit save actions and wallpaper action',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('Save image'), findsOneWidget);
    expect(find.text('Save & share'), findsOneWidget);
    expect(find.text('Wallpaper'), findsOneWidget);
    expect(
      find.text(
          'Saves to Pictures/FractalForge. No storage permission prompt.'),
      findsOneWidget,
    );
  });

  testWidgets('quick presets show export specs before selection',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('JPG • Instagram (1080×1080)'), findsOneWidget);
    expect(find.text('PNG • 4K (3840×2160)'), findsOneWidget);
    expect(
        find.text('PNG (PNG fallback) • Full HD (1920×1080)'), findsOneWidget);
    expect(find.text('PNG • Full HD (1920×1080)'), findsOneWidget);
  });

  testWidgets('WebP preset summary advertises PNG fallback truthfully',
      (tester) async {
    await pumpSheet(
      tester,
      initialOptions: ExportPresets.webOptimized,
    );

    await tester.scrollUntilVisible(find.text('PNG (PNG fallback)'), 120);
    expect(find.text('PNG (PNG fallback)'), findsOneWidget);
    expect(
      find.text('WebP is not encoded yet; exports use PNG fallback.'),
      findsOneWidget,
    );
    expect(find.text('85%'), findsNothing);
  });

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

  testWidgets('wallpaper action triggers setWallpaper export action',
      (tester) async {
    final submission = await pumpSheetAndSubmit(
      tester,
      submitButton: find.byKey(const ValueKey('exportWallpaperButton')),
    );

    expect(submission?.action, ExportAction.setWallpaper);
  });

  testWidgets('export actions fit narrow screens', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpSheet(tester);

    expect(find.byKey(const ValueKey('exportSaveButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('exportShareButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('exportWallpaperButton')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('exportSaveButton'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('exportShareButton'))).dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop sheet is width constrained and hides wallpaper',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpSheet(tester);

    expect(tester.getSize(find.byType(ExportOptionsSheet)).width, 720);
    expect(find.byKey(const ValueKey('exportWallpaperButton')), findsNothing);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('quote overlay text is included in submitted options',
      (tester) async {
    final harness = await pumpSheet(tester);

    await tester.tap(find.text('Customize').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('exportQuoteTextField')),
      'Dream in gradients',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('exportSaveButton')));
    await tester.pumpAndSettle();

    expect(harness.submission?.options.quoteText, 'Dream in gradients');
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

  testWidgets('preset summary uses actual oriented target dimensions',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpSheet(
      tester,
      initialOptions: const ExportOptions(
        resolution: ExportResolution.fullHd,
      ),
    );

    expect(find.text('1080×1920'), findsOneWidget);
    expect(find.text('1920×1080'), findsNothing);
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

    await tester.tap(find.text('Web'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Customize').last);
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
