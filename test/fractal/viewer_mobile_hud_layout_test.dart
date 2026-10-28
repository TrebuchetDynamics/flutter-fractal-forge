import 'package:flutter/material.dart';
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

  testWidgets('HUD has an opaque surface and readable label contrast',
      (tester) async {
    await pumpPhone(tester);
    final surface = tester
        .widget<Material>(find.byKey(const ValueKey('controlsHudSurface')))
        .color!;
    expect(surface.a, 1);
    final label = tester.widget<Text>(find.text('Iterations'));
    expect(label.style!.fontSize, greaterThanOrEqualTo(13));
    final contrast = (label.style!.color!.computeLuminance() + 0.05) /
        (surface.computeLuminance() + 0.05);
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
      'large-target preference grows HUD header sliders chips and footer to 56',
      (tester) async {
    await pumpAccessibleHud(tester, large: true);
    for (final icon in [Icons.expand_more_rounded, Icons.close_rounded]) {
      final target = find
          .ancestor(of: find.byIcon(icon), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(target), const Size(56, 56));
    }
    for (final element in find.byType(Slider).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height,
          greaterThanOrEqualTo(56));
    }
    final chip = find.byType(ChoiceChip).first;
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    expect(tester.getSize(chip).height, greaterThanOrEqualTo(56));
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
