import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _orderedTools = [
  'viewerControlsButton',
  'viewerPaletteButton',
  'viewerRandomFractalFab',
  'viewerOverflowMenu',
];

Future<AutoExploreService> _pumpToolbar(WidgetTester tester,
    {required Size viewport,
    bool largeTargets = false,
    bool highContrast = false,
    bool supportsAuxiliaryTools = true,
    VoidCallback? onAutoExploreSettings,
    Locale locale = const Locale('en'),
    double textScale = 1,
    EdgeInsets viewPadding = EdgeInsets.zero,
    EdgeInsets gestures = EdgeInsets.zero,
    void Function(AutoExploreService)? configurePlayback}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  SharedPreferences.setMockInitialValues({
    'accessibility_large_targets': largeTargets,
    'accessibility_reduced_motion': true,
  });
  final accessibility = await AccessibilityService.create();
  final fractal = FractalController(ModuleRegistry());
  final autoExplore = AutoExploreService(controller: fractal);
  configurePlayback?.call(autoExplore);
  final animation = AnimationController(vsync: tester, value: 1);
  addTearDown(() {
    animation.dispose();
    autoExplore.dispose();
    fractal.dispose();
    accessibility.dispose();
  });
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<AccessibilityService>.value(value: accessibility),
    ],
    child: MaterialApp(
      locale: locale,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            viewPadding: viewPadding,
            systemGestureInsets: gestures,
          ),
          child: child!),
      theme: highContrast ? AppTheme.highContrast : AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<AutoExploreService>.value(
          value: autoExplore,
          child: Scaffold(
            body: FractalViewControls(
              fabController: animation,
              supportsAuxiliaryTools: supportsAuxiliaryTools,
              isExporting: false,
              kaleidoscopeEnabled: false,
              kaleidoscopeSectors: 8,
              kaleidoscopeMirror: true,
              fractalMusicEnabled: false,
              fourierEnabled: false,
              textOverlayEnabled: false,
              actions: FractalViewControlActions(
                openAutoExploreSettings: onAutoExploreSettings,
                toggleFullscreen: () {},
                openRandomFractal: () {},
                openControls: () {},
                randomizeParams: () {},
                cycleColorScheme: () {},
                openPalettePicker: () {},
                toggleKaleidoscope: () {},
                setKaleidoscopeSectors: (_) {},
                setKaleidoscopeMirror: (_) {},
                openExport: () {},
                shareLink: () {},
                shareImage: () {},
                toggleTextOverlay: () {},
                editTextOverlay: () {},
                openLooper: () {},
                toggleFractalMusic: () {},
                toggleFourier: () {},
                openFourierSettings: () {},
                reportFractal: () {},
                openWallpaper: () {},
              ),
            ),
          )),
    ),
  ));
  await tester.pumpAndSettle();
  return autoExplore;
}

Finder _tool(String key) => find.byKey(ValueKey(key));
Future<void> _openMore(WidgetTester tester) async {
  await tester.ensureVisible(_tool('viewerOverflowMenu'));
  await tester.tap(_tool('viewerOverflowMenu'));
  await tester.pumpAndSettle();
}

void main() {
  for (final viewport in [
    const Size(360, 900),
    const Size(1200, 400),
    const Size(240, 400)
  ]) {
    for (final large in [false, true]) {
      for (final locale in const [Locale('en'), Locale('es')]) {
        for (final scale in [1.0, 3.0]) {
          testWidgets(
              'four labeled primaries $viewport large=$large ${locale.languageCode} scale=$scale',
              (tester) async {
            await _pumpToolbar(tester,
                viewport: viewport,
                largeTargets: large,
                highContrast: large,
                locale: locale,
                textScale: scale);
            final target = large ? 56.0 : 48.0;
            for (final key in _orderedTools) {
              final tool = _tool(key);
              await Scrollable.ensureVisible(tester.element(tool),
                  alignment: 0.5);
              await tester.pumpAndSettle();
              final rect = tester.getRect(tool);
              expect(rect.width, greaterThanOrEqualTo(target), reason: key);
              expect(rect.height, greaterThanOrEqualTo(target), reason: key);
              expect(rect.left, greaterThanOrEqualTo(16), reason: key);
              expect(rect.right, lessThanOrEqualTo(viewport.width - 16),
                  reason: key);
              expect(tool.hitTestable(), findsOneWidget, reason: key);
            }
            final first = tester.getRect(_tool(_orderedTools.first));
            final third = tester.getRect(_tool(_orderedTools[2]));
            if (scale == 1 && viewport.width >= 328) {
              expect(first.top, third.top);
            } else {
              expect(third.top, greaterThan(first.top));
            }
            expect(tester.getSize(_tool('viewerFabColumn')).width,
                lessThanOrEqualTo(440));
            await _openMore(tester);
            for (final key in [
              'viewerRandomParamsButton',
              'viewerColorCycleButton',
              'viewerAutoExploreButton',
              'viewerLooperFab',
              'viewerKaleidoscopeFab',
              'viewerFourierFab',
              'viewerTextOverlayFab',
              'viewerFractalMusicFab',
              'viewerFullscreenButton'
            ]) {
              final tool = _tool(key);
              await Scrollable.ensureVisible(tester.element(tool),
                  alignment: 0.5);
              await tester.pumpAndSettle();
              expect(tester.getSize(tool).width, greaterThanOrEqualTo(target),
                  reason: key);
              expect(tester.getSize(tool).height, greaterThanOrEqualTo(target),
                  reason: key);
              expect(tool.hitTestable(), findsOneWidget, reason: key);
            }
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('toolbar owns max viewPadding/gesture insets plus sixteen',
      (tester) async {
    await _pumpToolbar(tester,
        viewport: const Size(360, 780),
        viewPadding: const EdgeInsets.fromLTRB(24, 24, 8, 48),
        gestures: const EdgeInsets.fromLTRB(8, 0, 32, 64));
    final rect = tester.getRect(_tool('viewerFabColumn'));
    expect(rect.left, 40);
    expect(rect.right, 312);
    expect(rect.bottom, 700);
  });

  testWidgets('short viewport scrolls the primary grid vertically',
      (tester) async {
    await _pumpToolbar(tester, viewport: const Size(240, 100), textScale: 1);
    final more = _tool('viewerOverflowMenu');
    await tester.ensureVisible(more);
    await tester.pumpAndSettle();
    expect(more.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visual, tab and semantic order follow four primary groups',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpToolbar(tester, viewport: const Size(360, 1000));
      var previousRight = 0.0;
      for (var index = 0; index < _orderedTools.length; index++) {
        final key = _orderedTools[index];
        final tool = _tool(key);
        final rect = tester.getRect(tool);
        expect(rect.left, greaterThanOrEqualTo(previousRight));
        previousRight = rect.right;
        final semantic = tester.widget<Semantics>(find.descendant(
            of: tool,
            matching: find.byWidgetPredicate((widget) =>
                widget is Semantics && widget.properties.sortKey != null)));
        expect((semantic.properties.sortKey! as OrdinalSortKey).order, index);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final gesture =
            find.descendant(of: tool, matching: find.byType(GestureDetector));
        expect(Focus.of(tester.element(gesture)).hasFocus, isTrue, reason: key);
      }
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('NumberWall omits AutoExplore even with a local service',
      (tester) async {
    await _pumpToolbar(tester,
        viewport: const Size(360, 780), supportsAuxiliaryTools: false);
    await _openMore(tester);
    for (final key in [
      'viewerAutoExploreButton',
      'viewerLooperFab',
      'viewerKaleidoscopeFab',
      'viewerFourierFab',
      'viewerTextOverlayFab',
      'viewerFractalMusicFab'
    ]) {
      expect(_tool(key), findsNothing);
    }
    expect(_tool('viewerColorCycleButton'), findsOneWidget);
    expect(_tool('viewerRandomParamsButton'), findsOneWidget);
  });

  testWidgets('AutoExplore offers settings by long press and explicit Options',
      (tester) async {
    var settings = 0;
    await _pumpToolbar(tester,
        viewport: const Size(360, 900),
        onAutoExploreSettings: () => settings++);
    for (final secondary in [true, false]) {
      await _openMore(tester);
      final tool = _tool(secondary
          ? 'viewerAutoExploreButton'
          : 'viewerAutoExploreButtonOptions');
      await tester.ensureVisible(tool);
      await tester.pumpAndSettle();
      if (secondary) {
        await tester.longPress(tool);
      } else {
        await tester.tap(tool);
      }
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    }
    expect(settings, 2);
  });

  for (final playback in ['stopped', 'active', 'paused', 'yielded']) {
    testWidgets(
        'More reprovides viewer-local exploration and handles $playback',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final service = await _pumpToolbar(tester,
            viewport: const Size(360, 900), configurePlayback: (service) {
          if (playback != 'stopped') service.start();
          if (playback == 'paused') service.pause();
          if (playback == 'yielded') service.onUserInteractionStart();
        });
        await _openMore(tester);
        final tool = _tool('viewerAutoExploreButton');
        await Scrollable.ensureVisible(tester.element(tool), alignment: 0.5);
        await tester.pumpAndSettle();
        final button = tester.widget<FloatingActionButtonWidget>(tool);
        expect(button.selected, playback == 'active');
        if (playback == 'yielded') {
          expect(find.text('Auto-pilot paused while you adjust the view.'),
              findsOneWidget);
          expect(button.tooltip, 'Resume');
        }
        final data = tester
            .getSemantics(find.bySemanticsLabel(button.tooltip))
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        final size = tester.getSize(tool);
        final gesture =
            find.descendant(of: tool, matching: find.byType(GestureDetector));
        Focus.of(tester.element(gesture)).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(service.isPaused, playback == 'active');
        expect(service.isExploring, isTrue);
        expect(service.pausedByUserCorrection, isFalse);
        await _openMore(tester);
        await Scrollable.ensureVisible(tester.element(tool), alignment: 0.5);
        await tester.pumpAndSettle();
        expect(tester.getSize(tool), size);
        service.stop();
        await tester.pump();
      } finally {
        semantics.dispose();
      }
    });
  }
}
