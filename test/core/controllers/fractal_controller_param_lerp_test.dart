import 'dart:math';

import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets runs Timer.periodic on the fake clock driven by pump.
  testWidgets(
      'zooming during the randomize animation keeps the iteration increase',
      (tester) async {
    final controller = FractalController(ModuleRegistry());
    addTearDown(controller.dispose);
    expect(controller.module.id, 'mandelbrot');

    // Seed 4 lowers iterations (350 -> 84), so the animation target is below
    // the adaptive increase and would overwrite it.
    controller.randomizeParams(random: Random(4));
    await tester.pump(const Duration(milliseconds: 100));

    final before = controller.params['iterations']! as num;
    controller.updateView(
      controller.view.copyWith(zoom: controller.view.zoom * 1e6),
      adaptIterationsForZoom: true,
    );
    final increased = controller.params['iterations']! as num;
    expect(increased, greaterThan(before),
        reason: 'the deep zoom must trigger an adaptive increase');

    await tester.pump(const Duration(milliseconds: 700));

    expect(controller.params['iterations']! as num,
        greaterThanOrEqualTo(increased));
  });
}
