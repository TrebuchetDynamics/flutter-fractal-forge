import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/export_options.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/export/export_service.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_guard.dart';
import '../semantics/interactive_name_audit.dart';
import '../shared/a11y_test_helpers.dart';

/// Stands in for the real export backend.
///
/// The real one opens a directory picker and writes to the user's filesystem,
/// which is why this sheet had never been rendered in a test and was reviewed
/// by reading the code instead of by measuring it.
class _FakeExportService extends ExportService {
  final List<String> savedFilenames = [];
  int captureCalls = 0;

  @override
  Future<bool> chooseLinuxExportDirectory() async => true;

  @override
  Future<Uint8List> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 1.0,
  }) async {
    captureCalls++;
    // A real capture needs a live RenderRepaintBoundary; the sheet only uses
    // the resulting path, so the bytes themselves do not matter.
    return Uint8List.fromList(const [0x89, 0x50, 0x4E, 0x47]);
  }

  @override
  String generateFilename({
    String prefix = 'fractal',
    required ExportFormat format,
    String? fractalType,
  }) =>
      '${prefix}_${fractalType ?? 'x'}.${format.name}';

  // Deliberately writes nothing. A real `writeAsBytes` is filesystem async
  // that `tester.pump` does not drain, so the flow stalled here and the
  // screenshot half of the report never ran. The sheet only shows the path.
  @override
  Future<File> saveBytes(Uint8List bytes, {required String filename}) async {
    savedFilenames.add(filename);
    return File('/fake-export/$filename');
  }
}

void main() {
  group('GPU debug report sheet accessibility', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;
    late _FakeExportService exportService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // cpuOnly is what puts the CPU fallback banner on screen, and its Report
      // button is the only way into this sheet.
      SharedPreferences.setMockInitialValues(
        {'renderer_backend_mode': RendererBackendMode.cpuOnly.name},
      );
      registry = ModuleRegistry();
      controller = FractalController(registry);
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
      exportService = _FakeExportService();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildApp(
        {double textScale = 1.0, Locale locale = const Locale('en')}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FractalController>.value(value: controller),
          Provider<ModuleRegistry>.value(value: registry),
          ChangeNotifierProvider<AccessibilityService>.value(
            value: accessibilityService,
          ),
          ChangeNotifierProvider<RendererSettingsService>.value(
            value: rendererSettingsService,
          ),
          Provider<ExplorationStatsService?>.value(value: null),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: FractalViewerScreen(exportService: exportService),
        ),
      );
    }

    /// Opens the sheet the way a user does: through the CPU fallback banner.
    Future<void> openReport(
      WidgetTester tester, {
      double textScale = 1.0,
      Locale locale = const Locale('en'),
      String reportLabel = 'Report',
    }) async {
      await tester.pumpWidget(buildApp(textScale: textScale, locale: locale));
      await pumpAccessibilityTestFrames(tester);

      final report = find.widgetWithText(OutlinedButton, reportLabel);
      expect(report, findsOneWidget,
          reason: 'the CPU fallback banner never rendered, so nothing below '
              'would be measuring the sheet');
      await tester.tap(report);
      await pumpAccessibilityTestFrames(tester);
    }

    testWidgets('the injected service is what the report writes through',
        (tester) async {
      await openReport(tester);

      // Proves the seam rather than the sheet: with the viewer building
      // `const ExportService()` inline these counters stay at zero and the
      // real picker blocks the flow.
      expect(exportService.savedFilenames, isNotEmpty,
          reason: 'the report never reached the injected ExportService');
      expect(exportService.savedFilenames.first, startsWith('gpu_debug_'));
      expect(exportService.captureCalls, 1);
      expect(find.text('GPU Debug Report'), findsOneWidget);
    });

    testWidgets('every control in the sheet is named exactly once',
        (tester) async {
      final handle = tester.ensureSemantics();
      await openReport(tester);

      final root = semanticsRoot(tester);
      expect(operableControlNames(root), contains('Close'),
          reason: 'the sheet did not enter, so the rest would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await openReport(tester);

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // The sheet stacks a header, two saved-path lines, a scrollable JSON block
    // and a Wrap of buttons — the shape that overflowed on every other sheet
    // audited so far once the text scale grew.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
      ]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await expectNoOverflow(
            () => openReport(tester, textScale: scale),
            reason: '$scale x on $size',
          );
          await disposeAccessibilityTestWidget(tester);
        });
      }
    }

    // The banner is a Positioned child of the viewer Stack, so nothing clips it
    // and no overflow is reported when it outgrows its slot — it just paints
    // past the bottom edge and stops hit-testing. Before the message was capped
    // and the banner made scrollable, Report sat 91px below the viewport at
    // 2.0x in landscape and up to 343px below at 3.0x, taking the only route
    // out of CPU fallback with it.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
      ]) {
        testWidgets('Report stays reachable at ${scale}x on $size',
            (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildApp(textScale: scale));
          await pumpAccessibilityTestFrames(tester);

          final report = find.widgetWithText(OutlinedButton, 'Report');
          expect(report, findsOneWidget);

          // Scrolling counts as reachable; painting off the edge does not.
          await tester.ensureVisible(report);
          await tester.pump();

          final rect = tester.getRect(report);
          expect(
            rect.top >= 0 && rect.bottom <= size.height,
            isTrue,
            reason: 'Report is at $rect on a $size viewport and cannot be '
                'scrolled into it',
          );
          await disposeAccessibilityTestWidget(tester);
        });
      }
    }

    testWidgets('its copy localizes', (tester) async {
      await openReport(tester,
          locale: const Locale('es'), reportLabel: 'Reportar');

      expect(find.text('GPU Debug Report'), findsNothing);
    });
  });
}
