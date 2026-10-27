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
  'viewerRandomParamsButton',
  'viewerColorCycleButton',
  'viewerRandomFractalFab',
  'viewerAutoExploreButton',
  'viewerLooperFab',
  'viewerKaleidoscopeFab',
  'viewerFourierFab',
  'viewerTextOverlayFab',
  'viewerFractalMusicFab',
  'viewerExportButton',
  'viewerFullscreenButton',
];

Future<void> _pumpToolbar(WidgetTester tester,
    {required Size viewport,
    bool largeTargets = false,
    bool highContrast = false}) async {
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
      ChangeNotifierProvider<AutoExploreService>.value(value: autoExplore),
    ],
    child: MaterialApp(
      theme: highContrast ? AppTheme.highContrast : AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FractalViewControls(
          fabController: animation,
          isExporting: false,
          kaleidoscopeEnabled: false,
          kaleidoscopeSectors: 8,
          kaleidoscopeMirror: true,
          fractalMusicEnabled: false,
          fourierEnabled: false,
          textOverlayEnabled: false,
          actions: FractalViewControlActions(
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
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final viewport in [const Size(360, 900), const Size(1200, 400)]) {
    for (final large in [false, true]) {
      for (final highContrast in [false, true]) {
        testWidgets(
            'every toolbar circle matches at $viewport large=$large '
            'contrast=$highContrast', (tester) async {
          await _pumpToolbar(tester,
              viewport: viewport,
              largeTargets: large,
              highContrast: highContrast);
          final touchSize = large ? 56.0 : 48.0;
          for (final key in _orderedTools) {
            final tool = find.byKey(ValueKey(key));
            expect(tester.getSize(tool), Size.square(touchSize), reason: key);
            final circle = find.descendant(
              of: tool,
              matching: find.byWidgetPredicate((widget) =>
                  widget is AnimatedContainer &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).shape ==
                      BoxShape.circle),
            );
            expect(circle, findsOneWidget, reason: key);
            expect(tester.getSize(circle), Size.square(touchSize - 4),
                reason:
                    '$key painted circle must not shrink inside focus padding');
            final icon = tester.widget<Icon>(
                find.descendant(of: tool, matching: find.byType(Icon)));
            expect(icon.size, 20, reason: key);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('active exploration does not resize its toolbar circle',
      (tester) async {
    await _pumpToolbar(tester, viewport: const Size(360, 900));
    final tool = find.byKey(const ValueKey('viewerAutoExploreButton'));
    final service = tester.element(tool).read<AutoExploreService>();
    final circle =
        find.descendant(of: tool, matching: find.byType(AnimatedContainer));
    service.start();
    try {
      for (var frame = 0; frame < 3; frame++) {
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.getRect(circle).size, const Size.square(44));
        expect(tester.getRect(tool).size, const Size.square(48));
      }
    } finally {
      service.stop();
      await tester.pump();
    }
  });

  testWidgets('toolbar visual, tab and semantic order follow tool groups',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpToolbar(tester, viewport: const Size(360, 1000));
      var previousBottom = 0.0;
      for (var index = 0; index < _orderedTools.length; index++) {
        final key = _orderedTools[index];
        final tool = find.byKey(ValueKey(key));
        final rect = tester.getRect(tool);
        if (index > 0) {
          final grouped = [3, 5, 9].contains(index);
          expect(rect.top - previousBottom, grouped ? 12 : 8, reason: key);
        }
        previousBottom = rect.bottom;
        final semantic = tester.widget<Semantics>(find.descendant(
          of: tool,
          matching: find.byWidgetPredicate((widget) =>
              widget is Semantics && widget.properties.sortKey != null),
        ));
        expect((semantic.properties.sortKey! as OrdinalSortKey).order, index,
            reason: key);
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
}
