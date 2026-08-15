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
    double textScale = 1,
  }) async {
    final harness = _SheetHarness();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
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
        'Simple mode — choose a quick preset, then tap Save image or '
        'Save & share.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('tap Export or Share'), findsNothing);
    expect(
      find.text(
          'Saves to Pictures/FractalForge. No storage permission prompt.'),
      findsOneWidget,
    );
  });

  testWidgets('simple phone sheet hugs actions above its safe area',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(411, 731));
    tester.view.padding = const FakeViewPadding(bottom: 24);
    tester.binding.handleMetricsChanged();
    addTearDown(() async {
      tester.view.padding = FakeViewPadding.zero;
      tester.binding.handleMetricsChanged();
      await tester.binding.setSurfaceSize(null);
    });
    await pumpSheet(tester);

    final wallpaper = tester.getRect(
      find.byKey(const ValueKey('exportWallpaperButton')),
    );
    final screenBottom = tester.getRect(find.byType(Scaffold).first).bottom;

    expect(screenBottom - wallpaper.bottom, lessThanOrEqualTo(48));
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('exportWallpaperButton')),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('quick presets show export specs before selection',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('JPG • Instagram (1080×1080)'), findsOneWidget);
    expect(find.text('PNG • 4K (3840×2160)'), findsOneWidget);
    expect(find.text('JPG • Full HD (1920×1080)'), findsOneWidget);
    expect(find.text('PNG • Full HD (1920×1080)'), findsOneWidget);
  });

  testWidgets('Customize replaces quick presets with manual controls',
      (tester) async {
    bool hasQuickPresetsSection() {
      final list = tester.widget<ListView>(find.byType(ListView));
      final delegate = list.childrenDelegate as SliverChildListDelegate;
      return delegate.children.whereType<Column>().any(
            (section) => section.children.whereType<Text>().any(
                  (text) => text.data == 'Quick Presets',
                ),
          );
    }

    await pumpSheet(tester);

    expect(hasQuickPresetsSection(), isTrue);
    expect(find.byKey(const ValueKey('exportQuoteTextField')), findsNothing);

    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();

    expect(hasQuickPresetsSection(), isFalse);
    expect(find.byKey(const ValueKey('exportQuoteTextField')), findsOneWidget);

    await tester.tap(find.text('Simple'));
    await tester.pumpAndSettle();

    expect(hasQuickPresetsSection(), isTrue);
    expect(find.byKey(const ValueKey('exportQuoteTextField')), findsNothing);
  });

  testWidgets('web optimized preset advertises its actual JPG output',
      (tester) async {
    await pumpSheet(
      tester,
      initialOptions: ExportPresets.webOptimized,
    );

    // The sheet has two scrollables now — the options list and the capped
    // action area beneath it — so name the one that holds the summary.
    await tester.scrollUntilVisible(
      find.text('JPG'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('JPG'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.textContaining('WebP'), findsNothing);
  });

  testWidgets('manual format controls do not offer unsupported WebP',
      (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('Customize'));
    await tester.pumpAndSettle();
    expect(find.text('WebP'), findsNothing);
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

  testWidgets('Customize layout works on constrained screens', (tester) async {
    addTearDown(tester.view.reset);

    for (final layout in [
      (size: const Size(320, 568), textScale: 2.0),
      (size: const Size(640, 360), textScale: 1.0),
    ]) {
      tester.view.physicalSize = layout.size;
      tester.view.devicePixelRatio = 1;
      await pumpSheet(
        tester,
        initialOptions: const ExportOptions(
          resolution: ExportResolution.custom,
        ),
        textScale: layout.textScale,
      );

      await tester.scrollUntilVisible(
        find.text('Customize'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Customize'));
      await tester.pumpAndSettle();

      expect(find.text('Simple'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Format'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Format'));
      await tester.pump();
      expect(
        find.text('Format').hitTestable(),
        findsOneWidget,
        reason: 'Format must be operable at '
            '${layout.size} and ${layout.textScale}x text',
      );
      final formatControl = tester.widget<SegmentedButton<ExportFormat>>(
        find.byType(SegmentedButton<ExportFormat>),
      );
      expect(
        formatControl.direction,
        layout.size.width < 420 ? Axis.vertical : Axis.horizontal,
      );

      await tester.scrollUntilVisible(
        find.text('Width'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Width'));
      await tester.pump();

      final widthField = find.widgetWithText(TextField, '1920');
      final heightField = find.widgetWithText(TextField, '1080');
      if (layout.size.width < 420) {
        expect(
          tester.getTopLeft(heightField).dy,
          greaterThan(tester.getBottomLeft(widthField).dy),
        );
      } else {
        expect(
          tester.getTopLeft(heightField).dy,
          tester.getTopLeft(widthField).dy,
        );
      }

      expect(
        tester.takeException(),
        isNull,
        reason: 'Customize must not overflow at '
            '${layout.size} and ${layout.textScale}x text',
      );

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    }
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
