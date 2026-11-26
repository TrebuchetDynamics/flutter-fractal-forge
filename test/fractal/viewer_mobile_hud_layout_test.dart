import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  late FractalControllerWidgetHarness harness;

  setUp(() => harness = FractalControllerWidgetHarness());
  tearDown(() => harness.dispose());

  Future<void> pumpPhone(
    WidgetTester tester, {
    VoidCallback? onCanvasTap,
    double bottomInset = 48,
    double gestureInset = 0,
    double textScale = 1,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    tester.view.padding = FakeViewPadding(top: 24, bottom: bottomInset);
    tester.view.viewPadding = FakeViewPadding(top: 24, bottom: bottomInset);
    tester.view.systemGestureInsets = FakeViewPadding(bottom: gestureInset);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetSystemGestureInsets);
    await tester.pumpWidget(harness.wrapScaffold(
      Builder(
          builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCanvasTap,
                      child: const ColoredBox(color: Colors.greenAccent),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 328,
                    child: FractalControlsHud(),
                  ),
                ]),
              )),
      locale: locale,
      theme: AppTheme.dark,
    ));
    await tester.pumpAndSettle();
  }

  Future<void> pumpSelected(
    WidgetTester tester, {
    Size size = const Size(375, 667),
    Locale locale = const Locale('en'),
    double scale = 1,
    bool accessible = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    final accessibility = await AccessibilityService.create();
    addTearDown(accessibility.dispose);
    await accessibility.setLargeTargets(accessible);
    await accessibility.setHighContrast(accessible);
    await accessibility.setReducedMotion(accessible);
    await tester.pumpWidget(harness.wrapScaffold(
      ChangeNotifierProvider.value(
        value: accessibility,
        child: Builder(
            builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: Stack(children: [
                    const Positioned.fill(child: FractalRenderer()),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: size.height < 400 ? size.height : 328,
                      child: FractalControlsHud(onClose: () {}),
                    ),
                  ]),
                )),
      ),
      locale: locale,
      theme: accessible ? AppTheme.highContrast : AppTheme.dark,
    ));
    await tester.pumpAndSettle();
    final l10n =
        AppLocalizations.of(tester.element(find.byType(FractalControlsHud)))!;
    final label = harness.controller.module.parameters
        .firstWhere((p) => p.id == 'iterations')
        .label(l10n);
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('single slider isolates edits and exposes renderer pan and pinch',
      (tester) async {
    // Keep this gesture fixture below the zoom that adapts iterations.
    await harness.controller.applyPreset(harness
        .controller.module.builtInPresets
        .singleWhere((preset) => preset.id == 'mandelbrot-classic'));
    await pumpSelected(tester);
    expect(
        tester.getSize(find.byType(Slider)).height, greaterThanOrEqualTo(48));
    final surface = tester
        .widget<Material>(find.byKey(const ValueKey('controlsHudSurface')))
        .color!;
    for (final backing in [Colors.white, Colors.black]) {
      final background = Color.alphaBlend(surface, backing).computeLuminance();
      for (final text in [
        find.text('Iterations'),
        find.text('${harness.controller.params['iterations']}')
      ]) {
        final foreground =
            tester.widget<Text>(text).style!.color!.computeLuminance();
        final contrast = foreground > background
            ? (foreground + .05) / (background + .05)
            : (background + .05) / (foreground + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    }
    final initialPan = harness.controller.view.pan.clone();
    final initialZoom = harness.controller.view.zoom;
    final initialParams = Map.of(harness.controller.params);
    await tester.drag(find.byType(Slider), const Offset(70, 0));
    await tester.pumpAndSettle();
    expect(harness.controller.params['iterations'],
        isNot(initialParams['iterations']));
    expect(harness.controller.view.pan, initialPan);
    expect(harness.controller.view.zoom, initialZoom);
    final edited = Map.of(harness.controller.params);
    initialParams.remove('iterations');
    final otherParams = Map.of(edited)..remove('iterations');
    expect(otherParams, initialParams);
    // This point was inside the expanded 328px HUD, not merely above it.
    final exposed = Offset(50, 667 - 250);
    expect(tester.getRect(find.byKey(const ValueKey('controlsHudSurface'))).top,
        greaterThan(exposed.dy));
    await tester.dragFrom(exposed, const Offset(40, -20));
    await tester.pumpAndSettle();
    expect(harness.controller.view.pan, isNot(initialPan));
    final g1 = await tester.startGesture(exposed, pointer: 1);
    final g2 =
        await tester.startGesture(exposed + const Offset(80, 0), pointer: 2);
    await tester.pump();
    await g1.moveBy(const Offset(-25, 0));
    await g2.moveBy(const Offset(25, 0));
    await tester.pump();
    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();
    expect(harness.controller.view.zoom, isNot(initialZoom));
    expect(harness.controller.params, edited);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(ModalBarrier).hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected slider supports keyboard and semantic adjustments',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSelected(tester);
    final slider = find.byType(Slider);
    var reached = false;
    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final focused = FocusManager.instance.primaryFocus?.context;
      if (focused != null &&
          find
              .ancestor(of: find.byWidget(focused.widget), matching: slider)
              .evaluate()
              .isNotEmpty) {
        reached = true;
        break;
      }
    }
    expect(reached, isTrue);
    final before = harness.controller.params['iterations'];
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(harness.controller.params['iterations'], isNot(before));
    final node = tester.getSemantics(find.bySemanticsLabel('Iterations'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.increase), isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.decrease), isTrue);
    final afterKey = harness.controller.params['iterations'];
    node.owner!.performAction(node.id, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(
        harness.controller.params['iterations'], greaterThan(afterKey as int));
    node.owner!.performAction(node.id, SemanticsAction.decrease);
    await tester.pumpAndSettle();
    expect(harness.controller.params['iterations'], afterKey);
    semantics.dispose();
  });

  for (final size in const [Size(320, 568), Size(568, 320), Size(667, 280)]) {
    for (final locale in const [Locale('en'), Locale('es')]) {
      testWidgets('selected control fits $size at 3x ${locale.languageCode}',
          (tester) async {
        await pumpSelected(tester,
            size: size, locale: locale, scale: 3, accessible: true);
        final chooser =
            find.byKey(const ValueKey('controlsHudParameterChooser'));
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);
        for (final target in [
          chooser,
          slider,
          find.text('${harness.controller.params['iterations']}')
        ]) {
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          expect(target.hitTestable(), findsOneWidget);
          final rect = tester.getRect(target);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
        }
        expect(tester.getSize(slider).height, greaterThanOrEqualTo(56));
        expect(tester.getSize(chooser).height, greaterThanOrEqualTo(56));
        expect(
            tester
                .widget<Material>(
                    find.byKey(const ValueKey('controlsHudSurface')))
                .color!
                .a,
            1);
        expect(
            find.descendant(
                of: find.byType(FractalControlsHud),
                matching: find.byType(AnimatedSize)),
            findsNothing);
        await tester.ensureVisible(chooser);
        await tester.tap(chooser);
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
            tester.element(find.byType(FractalControlsHud)))!;
        final footer = find.text(l10n.randomize);
        await tester.ensureVisible(footer);
        await tester.pumpAndSettle();
        expect(footer.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final width in [768.0, 1440.0]) {
    testWidgets('wide $width HUD retains simultaneous sliders', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1024);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(harness.wrapScaffold(const FractalControlsHud()));
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.text('Iterations'), findsOneWidget);
      expect(find.text('Bailout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('collapsed HUD returns its empty overlay region to the canvas',
      (tester) async {
    var canvasTaps = 0;
    await pumpPhone(tester, onCanvasTap: () => canvasTaps++);
    await tester.tap(find.byIcon(Icons.expand_more_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Iterations'), findsNothing);
    await tester.tapAt(const Offset(24, 560));
    await tester.pump();
    expect(
        tester.getSize(find.byKey(const ValueKey('controlsHudSurface'))).height,
        lessThanOrEqualTo(120));
    expect(canvasTaps, 1,
        reason:
            'Collapsed controls must not reserve an invisible input/scrim region');
    expect(tester.takeException(), isNull);
  });

  testWidgets('HUD is translucent glass with readable label contrast',
      (tester) async {
    await pumpPhone(tester);
    final surfaceFinder = find.byKey(const ValueKey('controlsHudSurface'));
    final surface = tester.widget<Material>(surfaceFinder).color!;
    expect(surface.a, lessThan(1.0),
        reason: 'the fractal must stay visible through the overlay');
    expect(
      find.ancestor(of: surfaceFinder, matching: find.byType(BackdropFilter)),
      findsOneWidget,
      reason: 'translucency needs the blurred backdrop, not a flat tint',
    );

    final label = tester.widget<Text>(find.text('Iterations'));
    expect(label.style!.fontSize, greaterThanOrEqualTo(13));

    // Worst case: the overlay sits over a pure white part of the fractal.
    final overWhite = Color.alphaBlend(surface, const Color(0xFFFFFFFF));
    final contrast = (label.style!.color!.computeLuminance() + 0.05) /
        (overWhite.computeLuminance() + 0.05);
    expect(contrast, greaterThanOrEqualTo(4.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('HUD reserves gesture-only system insets', (tester) async {
    await pumpPhone(tester, bottomInset: 0, gestureInset: 24);
    final randomize = find.widgetWithText(FilledButton, 'Randomize');
    await tester.ensureVisible(randomize);
    await tester.pumpAndSettle();
    expect(tester.getRect(randomize).bottom, lessThanOrEqualTo(756));
    expect(randomize.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final scale in [2.0, 3.0]) {
      testWidgets(
          'HUD footer remains reachable ${locale.languageCode} at ${scale}x',
          (tester) async {
        await pumpPhone(tester, locale: locale, textScale: scale);
        final l10n = AppLocalizations.of(
            tester.element(find.byType(FractalControlsHud)))!;
        final randomize = find.widgetWithText(FilledButton, l10n.randomize);
        await tester.ensureVisible(randomize);
        await tester.pumpAndSettle();
        expect(tester.getRect(randomize).bottom, lessThanOrEqualTo(732));
        expect(randomize.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('last HUD action scrolls fully above three-button navigation',
      (tester) async {
    await pumpPhone(tester);
    final randomize = find.widgetWithText(FilledButton, 'Randomize');
    await tester.ensureVisible(randomize);
    await tester.pumpAndSettle();
    expect(tester.getRect(randomize).bottom, lessThanOrEqualTo(732),
        reason: 'Android navigation occupies the bottom 48 logical pixels');
    expect(randomize.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  Future<void> pumpAccessibleHud(
    WidgetTester tester, {
    bool large = false,
    bool appReduced = false,
    bool osReduced = false,
    Widget? content,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final accessibility = await AccessibilityService.create();
    addTearDown(accessibility.dispose);
    await accessibility.setLargeTargets(large);
    await accessibility.setReducedMotion(appReduced);
    await tester.pumpWidget(harness.wrapScaffold(
      ChangeNotifierProvider.value(
          value: accessibility,
          child: Builder(
            builder: (context) => MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(disableAnimations: osReduced),
              child: SizedBox(
                  height: 400, child: FractalControlsHud(content: content)),
            ),
          )),
      theme: AppTheme.dark,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'large-target preference grows HUD header sliders toggles and footer to 56',
      (tester) async {
    await pumpAccessibleHud(tester, large: true);
    for (final icon in [Icons.expand_more_rounded, Icons.close_rounded]) {
      final target = find
          .ancestor(
              of: find.byIcon(icon), matching: find.byType(GestureDetector))
          .first;
      expect(tester.getSize(target), const Size(56, 56));
    }
    for (final element in find.byType(Slider).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height,
          greaterThanOrEqualTo(56));
    }
    final effectToggle = find.widgetWithText(SwitchListTile, 'Kaleidoscope');
    await tester.ensureVisible(effectToggle);
    await tester.pumpAndSettle();
    expect(tester.getSize(effectToggle).height, greaterThanOrEqualTo(56));
    final randomize = find.widgetWithText(FilledButton, 'Randomize');
    await tester.ensureVisible(randomize);
    await tester.pumpAndSettle();
    expect(tester.getSize(randomize).height, greaterThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
  });

  for (final osReduced in [false, true]) {
    testWidgets(
        '${osReduced ? 'OS' : 'in-app'} reduced motion bypasses HUD size animation with custom content',
        (tester) async {
      await pumpAccessibleHud(tester,
          osReduced: osReduced,
          appReduced: !osReduced,
          content: const SingleChildScrollView(
              child: SizedBox(height: 500, child: Text('Custom controls'))));
      expect(
          find.descendant(
              of: find.byType(FractalControlsHud),
              matching: find.byType(AnimatedSize)),
          findsNothing);
      await tester.tap(find.byIcon(Icons.expand_more_rounded));
      await tester.pump();
      expect(find.text('Custom controls'), findsNothing);
      await tester.tap(find.byIcon(Icons.expand_less_rounded));
      await tester.pump();
      expect(find.text('Custom controls'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
