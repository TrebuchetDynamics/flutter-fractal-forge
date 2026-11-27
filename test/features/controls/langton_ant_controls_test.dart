import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractals/langton_ant_frame.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/langton_ant_view.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final (locale, error, apply) in const [
    ('en', 'Enter 2–20 letters, using only L or R.', 'Apply'),
    ('es', 'Introduce entre 2 y 20 letras, solo L o R.', 'Aplicar'),
  ]) {
    testWidgets('$locale editor rejects invalid turns and keeps the last rule',
        (tester) async {
      final registry = ModuleRegistry();
      final controller = FractalController(registry)
        ..selectModule(registry.byId('langton_ant'));
      addTearDown(controller.dispose);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: FractalControlsHud()),
        ),
      ));
      await tester.pumpAndSettle();
      final text = find.byKey(const Key('langtonAntRule'));
      for (final input in ['RLX', '', 'R', 'L' * 21]) {
        await tester.enterText(text, input);
        await tester.tap(find.text(apply));
        await tester.pumpAndSettle();
        expect(find.text(error), findsOneWidget);
        expect(controller.params['rule'], 'RL');
      }
      await tester.enterText(text, 'rllr');
      await tester.tap(find.text(apply));
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);
      expect(find.text('RLLR'), findsOneWidget);
      expect(controller.params['rule'], 'RLLR');

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 11000);
      expect(slider.min, 0);
      expect(slider.max, 1000000);
      slider.onChanged!(0);
      expect(controller.params['steps'], 0);
      slider.onChanged!(1000000);
      expect(controller.params['steps'], 1000000);
    });
  }

  testWidgets('Play grows the exact grid, updates Steps, and Pause freezes PNG',
      (tester) async {
    final harness = _AntHarness(steps: 0);
    addTearDown(harness.controller.dispose);
    await tester.pumpWidget(harness.app());
    await harness.waitForPaint(tester);

    await tester.tap(find.text('Play'));
    const tick = Duration(milliseconds: 50);
    var elapsed = Duration.zero;
    while (harness.steps < 11000 && elapsed < const Duration(seconds: 15)) {
      await tester.pump(tick);
      elapsed += tick;
    }
    expect(harness.steps, greaterThanOrEqualTo(11000));
    expect(elapsed, greaterThanOrEqualTo(const Duration(seconds: 10)));
    expect(tester.widget<Slider>(find.byType(Slider)).value, harness.steps);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    final paused = harness.steps;
    final fresh = LangtonAntFrame.simulate('RL', paused);
    expect(harness.painter(tester).frame.cells, fresh.cells);
    final png = await harness.capture(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(harness.steps, paused);
    expect(await harness.capture(tester), png);

    await tester.tap(find.text('Play'));
    await tester.pump(tick);
    expect(harness.steps, greaterThan(paused));
    tester.widget<Slider>(find.byType(Slider)).onChanged!(4000);
    await tester.pump();
    expect(harness.boundary.currentContext, isNull);
    expect(find.text('Computing ant grid…'), findsOneWidget);
    await harness.waitForPaint(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Play'), findsOneWidget);
    expect(harness.steps, 4000);
    expect(harness.painter(tester).frame.cells,
        LangtonAntFrame.simulate('RL', 4000).cells);
  });

  testWidgets('Play stops at one million steps', (tester) async {
    final harness = _AntHarness(steps: 995000);
    addTearDown(harness.controller.dispose);
    harness.controller.updateParam('rule', 'LLRR');
    await tester.pumpWidget(harness.app());
    await harness.waitForPaint(tester);

    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    final play =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Play'));
    expect(play.onPressed, isNull);
    expect(harness.painter(tester).frame.completedSteps, langtonAntMaxSteps);
    expect(
        tester.widget<Slider>(find.byType(Slider)).value, langtonAntMaxSteps);
    await tester.pump(const Duration(seconds: 1));
    expect(harness.steps, langtonAntMaxSteps);
  });

  testWidgets('system and app reduced motion prevent and stop Play',
      (tester) async {
    final harness = _AntHarness(steps: 0);
    addTearDown(harness.controller.dispose);
    SharedPreferences.setMockInitialValues({});
    final accessibility =
        AccessibilityService(await SharedPreferences.getInstance());
    addTearDown(accessibility.dispose);
    await tester.pumpWidget(
        harness.app(reducedMotion: true, accessibility: accessibility));
    await harness.waitForPaint(tester);
    expect(find.text('Play'), findsNothing);
    expect(find.text('Current step: 0'), findsOneWidget);

    await tester.pumpWidget(harness.app(accessibility: accessibility));
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 150));
    final paused = harness.steps;
    expect(paused, greaterThan(0));
    await accessibility.setReducedMotion(true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Play'), findsNothing);
    expect(find.text('Pause'), findsNothing);
    expect(harness.steps, paused);
  });

  testWidgets('renderer freeze stops playback and preserves the capture',
      (tester) async {
    final harness = _AntHarness(steps: 0);
    addTearDown(harness.controller.dispose);
    await tester.pumpWidget(harness.app());
    await harness.waitForPaint(tester);
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 50));
    final paused = harness.steps;
    expect(paused, greaterThan(0));
    final png = await harness.capture(tester);

    await tester.pumpWidget(harness.app(animationEnabled: false));
    await tester.pump(const Duration(seconds: 1));
    expect(harness.steps, paused);
    expect(await harness.capture(tester), png);
    expect(find.text('Pause'), findsNothing);

    await tester.pumpWidget(harness.app());
    expect(find.text('Play'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(harness.steps, paused);

    await tester.pumpWidget(
        harness.app(animationEnabled: false, gesturesEnabled: false));
    expect(find.text('Play'), findsNothing);
    expect(find.text('Current step: $paused'), findsNothing);
    expect(await harness.capture(tester), png);
  });

  testWidgets('backgrounding cancels playback without requiring a new frame',
      (tester) async {
    final harness = _AntHarness(steps: 0);
    addTearDown(harness.controller.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    await tester.pumpWidget(harness.app());
    await harness.waitForPaint(tester);
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 50));
    final paused = harness.steps;
    expect(paused, greaterThan(0));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 1));
    expect(harness.steps, paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(harness.steps, paused);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('the capture boundary never exposes an old ant request',
      (tester) async {
    final harness = _AntHarness(steps: 11000);
    addTearDown(harness.controller.dispose);
    harness.controller.updateParam('rule', 'LRRRRRLLR');

    await tester.pumpWidget(harness.app());
    await harness.waitForPaint(tester);
    expect(harness.painter(tester).frame.completedSteps, 11000);
    harness.controller.updateParam('steps', 1000000);
    await tester.pump();
    expect(harness.boundary.currentContext, isNull);
    await harness.waitForPaint(tester);
    expect(harness.painter(tester).frame.completedSteps, 1000000);
  });

  test('old saved states drop approximation settings; presets stay selectable',
      () async {
    final registry = ModuleRegistry();
    final module = registry.byId('langton_ant');
    final controller = FractalController(registry);
    addTearDown(controller.dispose);
    expect(
        await controller.loadState(
            module: module,
            params: {
              'iterations': 260,
              'bailout': 4.0,
              'unknown': 'ignored',
              'colorScheme': 3,
            },
            view: module.defaultPreset.view),
        isTrue);
    expect(controller.params, {'rule': 'RL', 'steps': 11000, 'colorScheme': 3});
    expect(module.builtInPresets.map((p) => p.name), [
      'RL',
      'RLR',
      'LLRR',
      'RLLR',
      'LRRRRRLLR',
      'LLRRRLRLRLLR',
      'RRLLLRLLLRRR'
    ]);
    for (final preset in module.builtInPresets) {
      await controller.applyPreset(preset);
      expect(controller.params['rule'], preset.name);
    }
    controller.updateParam('rule', 'RLX');
    expect(controller.params['rule'], module.builtInPresets.last.name);
  });
}

class _AntHarness {
  _AntHarness({required int steps}) {
    final registry = ModuleRegistry();
    controller = FractalController(registry)
      ..selectModule(registry.byId('langton_ant'))
      ..updateParam('steps', steps);
  }

  late final FractalController controller;
  final boundary = GlobalKey();
  int get steps => controller.params['steps'] as int;

  Widget app({
    bool reducedMotion = false,
    bool animationEnabled = true,
    bool gesturesEnabled = true,
    AccessibilityService? accessibility,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider<AccessibilityService?>.value(
              value: accessibility),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reducedMotion),
            child: child!,
          ),
          home: Scaffold(
              body: Column(children: [
            Expanded(
                child: FractalRenderer(
                    boundaryKey: boundary,
                    animationEnabled: animationEnabled,
                    gesturesEnabled: gesturesEnabled)),
            const FractalControlsHud(),
          ])),
        ),
      );

  LangtonAntPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(
        find.descendant(
            of: find.byKey(boundary), matching: find.byType(CustomPaint)),
      )
      .painter! as LangtonAntPainter;

  Future<void> waitForPaint(WidgetTester tester) async {
    for (var i = 0; i < 300 && boundary.currentContext == null; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(boundary.currentContext, isNotNull);
  }

  Future<List<int>> capture(WidgetTester tester) async =>
      (await tester.runAsync(() async {
        final render = boundary.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final image = await render.toImage();
        try {
          return (await image.toByteData(format: ImageByteFormat.png))!
              .buffer
              .asUint8List();
        } finally {
          image.dispose();
        }
      }))!;
}
