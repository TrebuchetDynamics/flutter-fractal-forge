import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  'viewerBreathingButton',
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
    bool isExporting = false,
    bool breathingAvailable = true,
    ValueChanged<String>? onAction,
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
              isExporting: isExporting,
              breathingAvailable: breathingAvailable,
              showFractalReport: true,
              kaleidoscopeEnabled: false,
              kaleidoscopeSectors: 8,
              kaleidoscopeMirror: true,
              breathingPlaying: false,
              fourierEnabled: false,
              textOverlayEnabled: false,
              actions: FractalViewControlActions(
                openAutoExploreSettings: onAutoExploreSettings,
                toggleFullscreen: () =>
                    onAction?.call('viewerFullscreenButton'),
                openRandomFractal: () =>
                    onAction?.call('viewerRandomFractalFab'),
                openControls: () => onAction?.call('viewerControlsButton'),
                randomizeParams: () =>
                    onAction?.call('viewerRandomParamsButton'),
                cycleColorScheme: () =>
                    onAction?.call('viewerColorCycleButton'),
                openPalettePicker: () => onAction?.call('viewerPaletteButton'),
                toggleKaleidoscope: () =>
                    onAction?.call('viewerKaleidoscopeFab'),
                setKaleidoscopeSectors: (_) {},
                setKaleidoscopeMirror: (_) {},
                openExport: () => onAction?.call('viewerOpenExportAction'),
                shareLink: () => onAction?.call('viewerShareLinkAction'),
                shareImage: () => onAction?.call('viewerShareImageAction'),
                toggleTextOverlay: () => onAction?.call('viewerTextOverlayFab'),
                editTextOverlay: () =>
                    onAction?.call('viewerTextOverlayFabOptions'),
                openLooper: () => onAction?.call('viewerLooperFab'),
                toggleBreathing: () => onAction?.call('viewerBreathingButton'),
                toggleFourier: () => onAction?.call('viewerFourierFab'),
                openFourierSettings: () =>
                    onAction?.call('viewerFourierFabOptions'),
                reportFractal: () => onAction?.call('viewerReportFractalFab'),
                openWallpaper: () => onAction?.call('viewerWallpaperAction'),
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
  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final viewport in const [
      Size(320, 780),
      Size(360, 780),
      Size(390, 780),
      Size(640, 240)
    ]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
            'whole primary labels ${locale.languageCode} $viewport x$scale',
            (tester) async {
          final calls = <String>[];
          await _pumpToolbar(tester,
              viewport: viewport,
              onAction: calls.add,
              locale: locale,
              textScale: scale,
              viewPadding: const EdgeInsets.fromLTRB(4, 24, 4, 32),
              gestures: const EdgeInsets.fromLTRB(8, 0, 8, 48));
          final visible = _orderedTools
              .where((key) => _tool(key).evaluate().isNotEmpty)
              .toList();
          expect(visible, contains('viewerOverflowMenu'));
          for (final key in visible) {
            final tool = _tool(key);
            final rect = tester.getRect(tool);
            expect(rect.width, greaterThanOrEqualTo(48), reason: key);
            expect(rect.height, greaterThanOrEqualTo(48), reason: key);
            expect(rect.bottom, lessThanOrEqualTo(viewport.height - 64),
                reason: key);
          }
          final captions = find.descendant(
              of: _tool('viewerFabColumn'), matching: find.byType(RichText));
          for (final element in captions.evaluate()) {
            final render = element.renderObject! as RenderParagraph;
            final painter = TextPainter(
                text: render.text,
                textDirection: render.textDirection,
                textScaler: render.textScaler)
              ..layout(maxWidth: render.size.width);
            expect(painter.computeLineMetrics(), hasLength(1),
                reason: '${render.text.toPlainText()} must not break mid-word');
            expect(painter.width, lessThanOrEqualTo(render.size.width + .01));
            painter.dispose();
          }
          await _openMore(tester);
          for (final key
              in _orderedTools.where((key) => !visible.contains(key))) {
            expect(_tool(key), findsOneWidget,
                reason: 'Overflow must retain $key');
            await tester.ensureVisible(_tool(key));
            await tester.pumpAndSettle();
            expect(_tool(key).hitTestable(), findsOneWidget);
          }
          // A primary can move, but it must never disappear or change callback.
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          for (final key
              in _orderedTools.where((key) => key != 'viewerOverflowMenu')) {
            if (!visible.contains(key)) await _openMore(tester);
            await tester.ensureVisible(_tool(key));
            await tester.pumpAndSettle();
            expect(tester.getSize(_tool(key)).width, greaterThanOrEqualTo(48));
            expect(tester.getSize(_tool(key)).height, greaterThanOrEqualTo(48));
            await tester.tap(_tool(key));
            await tester.pumpAndSettle();
            expect(calls.where((call) => call == key), hasLength(1));
          }
          expect(
              calls,
              _orderedTools
                  .where((key) => key != 'viewerOverflowMenu')
                  .toList());
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final locale in const [Locale('en'), Locale('es')]) {
    testWidgets(
        'More has localized hierarchy and contextual settings ${locale.languageCode}',
        (tester) async {
      final semantics = tester.ensureSemantics();

      final calls = <String>[];
      await _pumpToolbar(tester,
          viewport: const Size(320, 568),
          textScale: 3,
          locale: locale,
          highContrast: true,
          largeTargets: true,
          onAction: calls.add);
      await _openMore(tester);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(BottomSheet)))!;
      final headings = [
        l10n.viewerActionSectionSaveShare,
        l10n.viewerActionSectionExploreAnimate,
        l10n.viewerActionSectionVisualEffects,
        l10n.viewerActionSectionViewReport
      ];
      var previous = -1.0;
      for (final label in headings) {
        final heading = find.text(label);
        expect(heading, findsOneWidget);
        final top = tester.getTopLeft(heading).dy;
        expect(top, greaterThan(previous));
        previous = top;
        final wrapper = tester.widget<Semantics>(find
            .ancestor(
                of: heading,
                matching: find.byWidgetPredicate(
                    (w) => w is Semantics && w.properties.header == true))
            .first);
        expect(wrapper.properties.header, isTrue);
      }
      expect(find.text(l10n.viewerToolOptions), findsNothing);
      final settings = {
        'viewerRandomParamsButtonOptions': l10n.viewerActionSettingsControls,
        'viewerColorCycleButtonOptions': l10n.viewerActionSettingsPalette,
        'viewerKaleidoscopeFabOptions': l10n.viewerActionSettingsKaleidoscope,
        'viewerFourierFabOptions': l10n.viewerActionSettingsFourier,
        'viewerTextOverlayFabOptions': l10n.viewerActionSettingsText,
      };
      for (final entry in settings.entries) {
        final tool = _tool(entry.key);
        await tester.ensureVisible(tool);
        await tester.pumpAndSettle();
        expect(tester.widget<FloatingActionButtonWidget>(tool).tooltip,
            entry.value);
        expect(tester.getSize(tool).width, greaterThanOrEqualTo(56));
        expect(tester.getSize(tool).height, greaterThanOrEqualTo(56));
      }
      // The final row remains fully visible and activates exactly once.
      final report = _tool('viewerReportFractalFab');
      await tester.ensureVisible(report);
      await tester.pumpAndSettle();
      final viewport =
          tester.getRect(find.byKey(const ValueKey('viewerShortMoreViewport')));
      expect(viewport.contains(tester.getTopLeft(report)), isTrue);
      expect(
          tester.getBottomRight(report).dy, lessThanOrEqualTo(viewport.bottom));
      await tester.tap(report);
      await tester.pumpAndSettle();
      expect(calls, ['viewerReportFractalFab']);
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets(
      'suppressed unavailable Play keeps disabled semantics and tooltip',
      (tester) async {
    final semantics = tester.ensureSemantics();

    final calls = <String>[];
    await _pumpToolbar(tester,
        viewport: const Size(320, 568),
        textScale: 3,
        breathingAvailable: false,
        onAction: calls.add);
    expect(_tool('viewerBreathingButton'), findsNothing);
    await _openMore(tester);
    final play = _tool('viewerBreathingButton');
    await tester.ensureVisible(play);
    await tester.pumpAndSettle();
    final button = tester.widget<FloatingActionButtonWidget>(play);
    final l10n = AppLocalizations.of(tester.element(play))!;
    expect(button.tooltip, l10n.tooltipBreathingUnavailable);
    expect(button.onPressed, isNull);
    final data = tester
        .getSemantics(find.bySemanticsLabel(button.tooltip))
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    // ignore: deprecated_member_use
    expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
    await tester.tap(play);
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    expect(find.byType(BottomSheet), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
      'scaled overflow is export locked for pointer keyboard and semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();

    final calls = <String>[];
    await _pumpToolbar(tester,
        viewport: const Size(320, 568),
        textScale: 3,
        isExporting: true,
        onAction: calls.add);
    final more = _tool('viewerOverflowMenu');
    final button = tester.widget<FloatingActionButtonWidget>(more);
    expect(button.onPressed, isNull);
    final data = tester
        .getSemantics(find.bySemanticsLabel(button.tooltip))
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    await tester.tap(more);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(calls, isEmpty);
    semantics.dispose();
  });

  for (final viewport in [
    const Size(360, 900),
    const Size(1200, 400),
    const Size(240, 400)
  ]) {
    for (final large in [false, true]) {
      for (final locale in const [Locale('en'), Locale('es')]) {
        for (final scale in [1.0, 3.0]) {
          testWidgets(
              'adaptive labeled primaries $viewport large=$large ${locale.languageCode} scale=$scale',
              (tester) async {
            await _pumpToolbar(tester,
                viewport: viewport,
                largeTargets: large,
                highContrast: large,
                locale: locale,
                textScale: scale);
            final target = large ? 56.0 : 48.0;
            final visible = _orderedTools
                .where((key) => _tool(key).evaluate().isNotEmpty)
                .toList();
            for (final key in visible) {
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
            final first = tester.getRect(_tool(visible.first));
            final last = tester.getRect(_tool(visible.last));
            expect(first.top, last.top);
            expect(tester.getSize(_tool('viewerFabColumn')).width,
                lessThanOrEqualTo(440));
            await _openMore(tester);
            for (final key in [
              ..._orderedTools.where((key) => !visible.contains(key)),
              'viewerRandomParamsButton',
              'viewerColorCycleButton',
              'viewerAutoExploreButton',
              'viewerLooperFab',
              'viewerKaleidoscopeFab',
              'viewerFourierFab',
              'viewerTextOverlayFab',
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

  testWidgets('visual, tab and semantic order follow visible primary groups',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpToolbar(tester, viewport: const Size(360, 1000));
      var previousRight = 0.0;
      final visible = _orderedTools
          .where((key) => _tool(key).evaluate().isNotEmpty)
          .toList();
      for (final key in visible) {
        final index = _orderedTools.indexOf(key);
        final tool = _tool(key);
        final rect = tester.getRect(tool);
        expect(rect.left, greaterThanOrEqualTo(previousRight - 1e-6));
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
