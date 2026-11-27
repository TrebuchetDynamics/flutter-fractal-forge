import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/features/viewer/langton_ant_view.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

  testWidgets('the capture boundary never exposes an old ant request',
      (tester) async {
    final boundary = GlobalKey();
    Widget app(int steps) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LangtonAntView(
              boundaryKey: boundary,
              rule: 'LRRRRRLLR',
              steps: steps,
              colorScheme: 0,
              view: FractalViewState.initial(),
            ),
          ),
        );

    Future<LangtonAntPainter> waitForPaint() async {
      for (var i = 0; i < 300 && boundary.currentContext == null; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump();
      }
      final captured = find.byKey(boundary);
      expect(captured, findsOneWidget);
      final paint =
          find.descendant(of: captured, matching: find.byType(CustomPaint));
      return tester.widget<CustomPaint>(paint).painter! as LangtonAntPainter;
    }

    await tester.pumpWidget(app(11000));
    expect((await waitForPaint()).frame.completedSteps, 11000);
    await tester.pumpWidget(app(1000000));
    expect(boundary.currentContext, isNull);
    expect((await waitForPaint()).frame.completedSteps, 1000000);
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
