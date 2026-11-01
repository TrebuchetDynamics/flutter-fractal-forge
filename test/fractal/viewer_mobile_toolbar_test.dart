import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/auto_explore/auto_explore.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_view_controls.dart';
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
      VoidCallback? onFourier}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    SharedPreferences.setMockInitialValues(
        {'accessibility_reduced_motion': true});
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
            breathingPlaying: false,
            fourierEnabled: false,
            textOverlayEnabled: false,
            actions: FractalViewControlActions(
              toggleFullscreen: () {},
              openRandomFractal: onRandom ?? () {},
              openControls: onControls ?? () {},
              randomizeParams: onRandomize ?? () {},
              cycleColorScheme: () {},
              randomizePalette: onRandomizePalette ?? () {},
              previousFractal: onPrevious ?? () {},
              toggleMorphPlayback: onPlay ?? () {},
              openPalettePicker: onPalette ?? () {},
              toggleKaleidoscope: () {},
              setKaleidoscopeSectors: (_) {},
              setKaleidoscopeMirror: (_) {},
              openExport: () {},
              shareLink: () {},
              shareImage: () {},
              toggleTextOverlay: () {},
              editTextOverlay: () {},
              openLooper: () {},
              toggleBreathing: () {},
              toggleFourier: onFourier ?? () {},
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

  testWidgets(
      'primary controls are icon-only and compact above system navigation',
      (tester) async {
    var randomized = 0;
    var opened = 0;
    await pumpToolbar(tester,
        onRandomize: () => randomized++, onControls: () => opened++);
    // More actions, no painted captions.
    for (final caption in ['Play', 'Controls', 'Palette', 'Random', 'More']) {
      expect(find.text(caption), findsNothing);
    }
    for (final key in [
      'viewerPreviousFractalButton',
      'viewerMorphPlayButton',
      'viewerLooperFab',
      'viewerControlsButton',
      'viewerPaletteButton',
      'viewerRandomFractalFab',
      'viewerOverflowMenu',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }
    final toolbar =
        tester.getRect(find.byKey(const ValueKey('viewerFabColumn')));
    expect(toolbar.height, lessThanOrEqualTo(124));
    expect(toolbar.bottom, lessThanOrEqualTo(732));
    expect(find.byKey(const ValueKey('viewerFourierFab')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('viewerControlsButton')));
    await tester.pump();
    expect(randomized, 1);
    await tester.longPress(find.byKey(const ValueKey('viewerControlsButton')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary icon cells fill their full hit regions', (tester) async {
    await pumpToolbar(tester);
    for (final key in const [
      'viewerPreviousFractalButton',
      'viewerMorphPlayButton',
      'viewerLooperFab',
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
          reason: 'Opaque icon cells must cover the full hit target');
    }
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
      'viewerMorphPlayButton': 'play',
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
    expect(find.text('Export'), findsOneWidget);
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
