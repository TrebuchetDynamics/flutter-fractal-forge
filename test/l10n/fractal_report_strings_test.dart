import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/rendering/fractal_report_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/shared/a11y_test_helpers.dart';

/// Opens the report sheet from the viewer's report FAB.
///
/// Nothing touches the filesystem until "Save report" is pressed, so the sheet
/// itself renders without needing a seam for FractalReportService.
Future<void> openReportSheet(
  WidgetTester tester,
  Locale locale, {
  Size surfaceSize = const Size(400, 800),
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final registry = ModuleRegistry();
  final fractal = FractalController(registry);
  addTearDown(fractal.dispose);
  final accessibility = await AccessibilityService.create();
  final rendererSettings = await RendererSettingsService.create();
  addTearDown(rendererSettings.dispose);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<FractalController>.value(value: fractal),
      Provider<ModuleRegistry>.value(value: registry),
      ChangeNotifierProvider<AccessibilityService>.value(value: accessibility),
      ChangeNotifierProvider<RendererSettingsService>.value(
          value: rendererSettings),
      Provider<ExplorationStatsService?>.value(value: null),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      home: const FractalViewerScreen(),
    ),
  ));
  await pumpAccessibilityTestFrames(tester);

  await tester.tap(find.byKey(const ValueKey('viewerMoreActionsButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('viewerReportFractalButton')));
  await tester.pumpAndSettle();
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final es = lookupAppLocalizations(const Locale('es'));

  group('fractal report feedback', () {
    test('both messages interpolate their argument', () {
      expect(en.fractalReportSaved('/tmp/report.json'),
          contains('/tmp/report.json'));
      expect(es.fractalReportSaved('/tmp/report.json'),
          contains('/tmp/report.json'));
      expect(en.fractalReportFailed('disk full'), contains('disk full'));
      expect(es.fractalReportFailed('disk full'), contains('disk full'));
    });

    test('Spanish is translated, not copied from English', () {
      expect(es.fractalReportSaved('x'), isNot(en.fractalReportSaved('x')));
      expect(es.fractalReportFailed('x'), isNot(en.fractalReportFailed('x')));
    });

    // The viewer's report card and the GPU debug report are separate features
    // that happen to word this the same way today. They get separate keys so
    // either can be reworded without touching the other — both keys must
    // survive, but their text is free to match.
    test('the debug report keeps a key of its own', () {
      expect(en.debugReportSavedReport('/tmp/a'), contains('/tmp/a'));
      expect(es.debugReportSavedReport('/tmp/a'), contains('/tmp/a'));
    });

    // Both were built by interpolation, so a regression compiles and runs and
    // looks like working code, with no missing key to notice.
    test('neither snack bar hardcodes English any more', () {
      final source = File('lib/features/viewer/fractal_viewer_screen.dart')
          .readAsStringSync();
      expect(source, isNot(contains("'Saved report: ")));
      expect(source, isNot(contains("'Report failed: ")));
    });
  });

  group('report sheet copy', () {
    test('every dialog string has a distinct Spanish translation', () {
      for (final pair in <List<String>>[
        [en.reportDialogTitle, es.reportDialogTitle],
        [en.reportDialogSymptoms, es.reportDialogSymptoms],
        [en.reportDialogSymptomsHint, es.reportDialogSymptomsHint],
        [en.reportDialogNotes, es.reportDialogNotes],
        [en.reportDialogNotesHint, es.reportDialogNotesHint],
        [en.reportDialogSave, es.reportDialogSave],
        [en.reportDialogCopyJsonTitle, es.reportDialogCopyJsonTitle],
        [en.reportDialogCopiedJson, es.reportDialogCopiedJson],
      ]) {
        expect(pair[1], isNotEmpty);
        expect(pair[1], isNot(pair[0]), reason: 'untranslated: ${pair[0]}');
      }
    });

    // The tag strings are the report's data, not only its copy: they go into
    // the saved JSON verbatim for a maintainer to read. Translating them would
    // change what the report says, so the sheet localizes the label it shows
    // and leaves the stored value alone.
    test('the stored tag values stay plain ASCII', () {
      for (final tag in FractalReportService.defaultTags) {
        expect(RegExp(r'^[\x20-\x7E]+$').hasMatch(tag), isTrue,
            reason: '"$tag" is no longer a stable ASCII value');
      }
    });

    testWidgets('the sheet renders in English', (tester) async {
      await openReportSheet(tester, const Locale('en'));

      expect(find.text(en.reportDialogTitle), findsOneWidget);
      expect(find.text(en.reportDialogSymptoms), findsOneWidget);
      expect(find.text(en.reportDialogNotes), findsOneWidget);
      expect(find.text(en.reportDialogSave), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('Notes opens with a complete touch target on a phone',
        (tester) async {
      await openReportSheet(
        tester,
        const Locale('en'),
        surfaceSize: const Size(411, 731),
      );

      final field = find.byType(TextField);
      final scrollable = find.ancestor(
        of: field,
        matching: find.byType(SingleChildScrollView),
      );
      final fieldRect = tester.getRect(field);
      final viewportRect = tester.getRect(scrollable);
      final visibleTop =
          fieldRect.top.clamp(viewportRect.top, viewportRect.bottom);
      final visibleBottom =
          fieldRect.bottom.clamp(viewportRect.top, viewportRect.bottom);

      expect(
        visibleBottom - visibleTop,
        greaterThanOrEqualTo(48),
        reason: 'field=$fieldRect viewport=$viewportRect',
      );
      await disposeAccessibilityTestWidget(tester);
    });

    // The chips are the bulk of the sheet, so an untranslated chip row is the
    // most visible thing a Spanish user would be left looking at.
    testWidgets('the sheet and every tag chip render in Spanish',
        (tester) async {
      await openReportSheet(tester, const Locale('es'));

      expect(find.text(es.reportDialogTitle), findsOneWidget);
      expect(find.text(es.reportDialogSymptoms), findsOneWidget);
      expect(find.text(es.reportDialogNotes), findsOneWidget);
      expect(find.text(es.reportDialogSave), findsOneWidget);
      expect(find.text(es.buttonCancel), findsOneWidget);

      for (final tag in FractalReportService.defaultTags) {
        expect(find.text(tag, skipOffstage: false), findsNothing,
            reason: 'the tag "$tag" is showing its raw English value');
      }
      await disposeAccessibilityTestWidget(tester);
    });
  });
}
