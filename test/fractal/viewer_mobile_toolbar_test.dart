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
              randomizeParams: () {},
              cycleColorScheme: () {},
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
      'primary controls are labeled and compact above system navigation',
      (tester) async {
    var opened = 0;
    await pumpToolbar(tester, onControls: () => opened++);
    for (final label in ['Controls', 'Palette', 'Random', 'More']) {
      expect(find.text(label), findsOneWidget);
    }
    final toolbar =
        tester.getRect(find.byKey(const ValueKey('viewerFabColumn')));
    expect(toolbar.height, lessThanOrEqualTo(124));
    expect(toolbar.bottom, lessThanOrEqualTo(732));
    expect(find.byKey(const ValueKey('viewerFourierFab')), findsNothing);
    await tester.tapAt(tester.getCenter(find.text('Controls')));
    await tester.pump();
    expect(opened, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary captions and opaque paint fill their full hit regions',
      (tester) async {
    await pumpToolbar(tester);
    const captions = {
      'viewerControlsButton': 'Controls',
      'viewerPaletteButton': 'Palette',
      'viewerRandomFractalFab': 'Random',
      'viewerOverflowMenu': 'More',
    };
    for (final entry in captions.entries) {
      final hitRegion = tester.getRect(find.byKey(ValueKey(entry.key)));
      final caption = find.text(entry.value);
      final paint = find
          .ancestor(of: caption, matching: find.byType(IgnorePointer))
          .first;
      expect(tester.getRect(paint), hitRegion,
          reason:
              'Opaque captions must cover the underlying circular button completely');
      expect(tester.getCenter(caption).dx, closeTo(hitRegion.center.dx, .01),
          reason: 'Unequal label lengths must not shift primary alignment');
    }
  });

  testWidgets('the whole primary captions activate each callback exactly once',
      (tester) async {
    final calls = <String>[];
    await pumpToolbar(tester,
        onControls: () => calls.add('controls'),
        onPalette: () => calls.add('palette'),
        onRandom: () => calls.add('random'));
    for (final label in ['Controls', 'Palette', 'Random']) {
      // Captions are paint-only; their coordinates belong to the shared button.
      await tester.tapAt(tester.getCenter(find.text(label)));
      await tester.pumpAndSettle();
    }
    expect(calls, ['controls', 'palette', 'random']);
    await tester.tapAt(tester.getCenter(find.text('More')));
    await tester.pumpAndSettle();
    expect(find.text('Viewer actions'), findsOneWidget);
    expect(calls, ['controls', 'palette', 'random']);
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
