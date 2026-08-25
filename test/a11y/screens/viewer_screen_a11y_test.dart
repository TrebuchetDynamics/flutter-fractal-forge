import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/exploration_stats_service.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/overflow_guard.dart';
import '../semantics/interactive_name_audit.dart';
import '../shared/a11y_test_helpers.dart';

void main() {
  group('FractalViewerScreen accessibility', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildApp({double textScale = 1.0}) {
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
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const FractalViewerScreen(),
        ),
      );
    }

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });

    testWidgets('every control is named exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await pumpAccessibilityTestFrames(tester);

      final root = semanticsRoot(tester);
      expect(operableControlNames(root), isNotEmpty,
          reason: 'the FAB column never entered, so the rest of this and the '
              'guidelines above would pass vacuously');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      expect(findUnnamedSliders(root), isEmpty);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    testWidgets('Controls HUD removes the overlapping FAB rail and semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await pumpAccessibilityTestFrames(tester);

      await tester
          .longPress(find.byKey(const ValueKey('viewerRandomParamsButton')));
      await pumpAccessibilityTestFrames(tester);

      expect(find.byType(FractalControlsHud), findsOneWidget);
      expect(find.byKey(const ValueKey('viewerFourierFab')), findsNothing);
      expect(find.bySemanticsLabel('Fourier view off'), findsNothing);

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    /// Fullscreen strips the chrome down to the canvas and a single exit
    /// button, which is the one FAB with no long-press action, so it exercises
    /// a different branch of FloatingActionButtonWidget than the column does.
    testWidgets('fullscreen-unobtrusive mode stays accessible', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await pumpAccessibilityTestFrames(tester);

      await tester.tap(find.byKey(const ValueKey('viewerFullscreenButton')));
      await pumpAccessibilityTestFrames(tester);

      final root = semanticsRoot(tester);
      expect(operableControlNames(root), contains('Exit fullscreen view'));
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
      await disposeAccessibilityTestWidget(tester);
    });

    // The three guidelines above run at the default 800x600 and 1.0x only. The
    // viewer is absent from test/layout's sweep entirely, so nothing checked it
    // at a phone size, in landscape, or above 1.0x until now.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
        Size(568, 320),
      ]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await expectNoOverflow(
            () async {
              await tester.pumpWidget(buildApp(textScale: scale));
              await pumpAccessibilityTestFrames(tester);
            },
            reason: '$scale x on $size',
          );
          await disposeAccessibilityTestWidget(tester);
        });
      }
    }

    testWidgets('Palette menu does not overflow at 3.0x on a small phone',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await expectNoOverflow(
        () async {
          await tester.pumpWidget(buildApp(textScale: 3.0));
          await pumpAccessibilityTestFrames(tester);
          await tester.longPress(
            find.byKey(const ValueKey('viewerColorCycleButton')),
          );
          await pumpAccessibilityTestFrames(tester);
        },
        reason: 'Palette menu at 3.0x on Size(320, 568)',
      );
      expect(find.byType(GridView), findsOneWidget);
      await disposeAccessibilityTestWidget(tester);
    });

    for (final size in const [Size(360, 640), Size(640, 360)]) {
      testWidgets('meets guidelines at 2.0x on $size', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildApp(textScale: 2.0));
        await pumpAccessibilityTestFrames(tester);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        handle.dispose();
        await disposeAccessibilityTestWidget(tester);
      });
    }
  });
}
