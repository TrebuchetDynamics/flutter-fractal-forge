import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
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
