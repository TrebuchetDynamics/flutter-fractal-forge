import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
import 'package:flutter_fractals/features/viewer/chrome/viewer_tools.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpToolbar(WidgetTester tester,
      {VoidCallback? onControls,
      VoidCallback? onPalette,
      VoidCallback? onRandom,
      VoidCallback? onRandomize,
      VoidCallback? onRandomizePalette,
      VoidCallback? onPlay,
      VoidCallback? onPrevious,
      VoidCallback? onFourier,
      bool largeTargets = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    SharedPreferences.setMockInitialValues({
      'accessibility_reduced_motion': true,
      'accessibility_large_targets': largeTargets,
    });
    final accessibility = await AccessibilityService.create();
    final fractal = FractalController(ModuleRegistry());
    final explore = AutoExploreService(controller: fractal);
    final animation = AnimationController(vsync: tester, value: 1);
    addTearDown(() {
      animation.dispose();
      explore.dispose();
      fractal.dispose();
      accessibility.dispose();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AccessibilityService>.value(
            value: accessibility),
        ChangeNotifierProvider<AutoExploreService>.value(value: explore),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FractalViewControls(
            fabController: animation,
            canGoPreviousFractal: true,
            isExporting: false,
            kaleidoscopeEnabled: false,
            kaleidoscopeSectors: 8,
            kaleidoscopeMirror: true,
            looperPlaying: false,
            fourierEnabled: false,
            textOverlayEnabled: false,
            commands: ViewerCommands(
              motion: ViewerMotionCommands(
                toggleLooper: onPlay ?? () {},
                openLooper: () {},
                toggleFourier: onFourier ?? () {},
                openFourierSettings: () {},
              ),
              presentation: ViewerPresentationCommands(
                openControls: onControls ?? () {},
                randomizeParams: onRandomize ?? () {},
                openRandomFractal: onRandom ?? () {},
                toggleFullscreen: () {},
                cycleColorScheme: () {},
                openPalettePicker: onPalette ?? () {},
                toggleKaleidoscope: () {},
                setKaleidoscopeSectors: (_) {},
                setKaleidoscopeMirror: (_) {},
                toggleTextOverlay: () {},
                editTextOverlay: () {},
                randomizePalette: onRandomizePalette ?? () {},
                previousFractal: onPrevious ?? () {},
              ),
              share: ViewerShareCommands(
                openExport: () {},
                shareLink: () {},
                shareImage: () {},
                reportFractal: () {},
                openWallpaper: () {},
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('primary controls are labeled and wrap above system navigation',
      (tester) async {
    var randomized = 0;
    var opened = 0;
    await pumpToolbar(tester,
        onRandomize: () => randomized++, onControls: () => opened++);
    for (final caption in [
      'Previous fractal',
      'Play',
      'Randomize shape',
      'Randomize colors',
      'Random',
      'Save & share',
      'More',
      'Tap to randomize. Hold to edit.',
    ]) {
      expect(find.text(caption), findsOneWidget);
    }
    for (final key in [
      'viewerPreviousFractalButton',
      'viewerPlayButton',
      'viewerControlsButton',
      'viewerPaletteButton',
      'viewerRandomFractalFab',
      'viewerOverflowMenu',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }
    final toolbar =
        tester.getRect(find.byKey(const ValueKey('viewerFabColumn')));
    expect(toolbar.top, greaterThanOrEqualTo(24));
    expect(toolbar.bottom, lessThanOrEqualTo(716));
    final firstTop = tester
        .getRect(find.byKey(const ValueKey('viewerPreviousFractalButton')))
        .top;
    final rows = <double, int>{};
    for (final key in [
      'viewerPreviousFractalButton',
      'viewerPlayButton',
      'viewerControlsButton',
      'viewerPaletteButton',
      'viewerRandomFractalFab',
      'viewerSaveShareButton',
      'viewerOverflowMenu',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.top, greaterThanOrEqualTo(toolbar.top), reason: key);
      expect(rect.top, greaterThanOrEqualTo(firstTop), reason: key);
      expect(rect.bottom, lessThanOrEqualTo(toolbar.bottom), reason: key);
      rows.update(rect.top, (count) => count + 1, ifAbsent: () => 1);
    }
    // Whole-word randomize captions need wider cells than the old short names.
    expect(rows.values.toList()..sort(), [1, 2, 2, 2]);
    expect(find.byKey(const ValueKey('viewerFourierFab')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('viewerControlsButton')));
    await tester.pump();
    expect(randomized, 1);
    await tester.longPress(find.byKey(const ValueKey('viewerControlsButton')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'large targets keep labeled actions balanced inside a narrow phone',
      (tester) async {
    await pumpToolbar(tester, largeTargets: true);
    const keys = [
      'viewerPreviousFractalButton',
      'viewerPlayButton',
      'viewerControlsButton',
      'viewerPaletteButton',
      'viewerRandomFractalFab',
      'viewerSaveShareButton',
      'viewerOverflowMenu',
    ];
    final rects = [
      for (final key in keys) tester.getRect(find.byKey(ValueKey(key))),
    ];
    for (final rect in rects) {
      expect(rect.width, greaterThanOrEqualTo(56));
      expect(rect.height, greaterThanOrEqualTo(56));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(360));
    }
    final rows = <double, int>{};
    for (final rect in rects) {
      rows.update(rect.top, (count) => count + 1, ifAbsent: () => 1);
    }
    final counts = rows.values.toList()..sort();
    expect(counts.last - counts.first, lessThanOrEqualTo(1));
    final rail =
        tester.widget<Material>(find.byKey(const ValueKey('viewerFabColumn')));
    expect(rail.color, AppTheme.dark.colorScheme.surface);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary labeled cells keep their paint inside full hit regions',
      (tester) async {
    await pumpToolbar(tester);
    for (final key in const [
      'viewerPreviousFractalButton',
      'viewerPlayButton',
      'viewerControlsButton',
      'viewerPaletteButton',
      'viewerRandomFractalFab',
      'viewerOverflowMenu',
    ]) {
      final hitRegion = tester.getRect(find.byKey(ValueKey(key)));
      expect(hitRegion.width, greaterThanOrEqualTo(48), reason: key);
      expect(hitRegion.height, greaterThanOrEqualTo(48), reason: key);
      final stack = find
          .ancestor(of: find.byKey(ValueKey(key)), matching: find.byType(Stack))
          .first;
      final paint = find
          .descendant(of: stack, matching: find.byType(IgnorePointer))
          .first;
      expect(tester.getRect(paint), hitRegion,
          reason: 'The paint layer must cover the full hit target');
      final cell = tester.widget<Container>(
          find.descendant(of: paint, matching: find.byType(Container)).first);
      expect(cell.margin, const EdgeInsets.all(4));
      final decoration = cell.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull, reason: key);
      final surfaces = tester
          .widgetList<Container>(
              find.descendant(of: stack, matching: find.byType(Container)))
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .where((decoration) => decoration.borderRadius != null)
          .toList();
      expect(surfaces, isNotEmpty, reason: '$key must have a rounded surface');
      for (final decoration in surfaces) {
        expect(decoration.border, isNotNull, reason: key);
      }
      final content = find.descendant(of: paint, matching: find.byType(Column));
      final bounds = tester.getRect(content);
      expect(hitRegion.contains(bounds.topLeft), isTrue, reason: key);
      expect(hitRegion.contains(bounds.bottomRight), isTrue, reason: key);
    }
    final rail =
        tester.widget<Material>(find.byKey(const ValueKey('viewerFabColumn')));
    expect(rail.color, AppTheme.dark.colorScheme.surface,
        reason: 'One shared surface groups the editing tools');
    expect(rail.elevation, 6);
    expect((rail.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(20));
  });

  testWidgets(
      'primary icons activate tap and long-press callbacks exactly once',
      (tester) async {
    final calls = <String>[];
    await pumpToolbar(tester,
        onRandomize: () => calls.add('randomize'),
        onRandomizePalette: () => calls.add('palette-random'),
        onRandom: () => calls.add('random'),
        onPlay: () => calls.add('play'),
        onPrevious: () => calls.add('previous'),
        onControls: () => calls.add('controls-sheet'),
        onPalette: () => calls.add('palette-sheet'));
    for (final entry in const {
      'viewerPreviousFractalButton': 'previous',
      'viewerPlayButton': 'play',
      'viewerControlsButton': 'randomize',
      'viewerPaletteButton': 'palette-random',
      'viewerRandomFractalFab': 'random',
    }.entries) {
      await tester.tap(find.byKey(ValueKey(entry.key)));
      await tester.pumpAndSettle();
      expect(calls, [entry.value], reason: entry.key);
      calls.clear();
    }
    await tester.longPress(find.byKey(const ValueKey('viewerControlsButton')));
    await tester.pumpAndSettle();
    expect(calls, ['controls-sheet']);
    calls.clear();
    await tester.longPress(find.byKey(const ValueKey('viewerPaletteButton')));
    await tester.pumpAndSettle();
    expect(calls, ['palette-sheet']);
    await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
    await tester.pumpAndSettle();
    expect(find.text('Viewer actions'), findsOneWidget);
  });

  testWidgets('More preserves named secondary tools and their callbacks',
      (tester) async {
    var toggled = 0;
    await pumpToolbar(tester, onFourier: () => toggled++);
    await tester.tap(find.byKey(const ValueKey('viewerOverflowMenu')));
    await tester.pumpAndSettle();
    expect(find.text('Fourier view off'), findsOneWidget);
    expect(find.text('Kaleidoscope off'), findsOneWidget);
    final fourier = find.byKey(const ValueKey('viewerFourierFab'));
    await tester.ensureVisible(fourier);
    await tester.pumpAndSettle();
    await tester.tap(fourier);
    await tester.pumpAndSettle();
    expect(toggled, 1);
    expect(find.text('Viewer actions'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
