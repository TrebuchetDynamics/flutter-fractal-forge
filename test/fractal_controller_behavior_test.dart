import 'dart:math';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FractalController', () {
    test('updateZoom clamps to [1e-9, 1e12]', () {
      final controller = FractalController(ModuleRegistry());

      controller.updateZoom(-1.0);
      expect(controller.view.zoom, 1e-9);

      controller.updateZoom(1e20);
      expect(controller.view.zoom, 1e12);

      controller.updateZoom(1.25);
      expect(controller.view.zoom, 1.25);
    });

    test('randomizeParams keeps values within schema bounds/options', () {
      final controller = FractalController(ModuleRegistry());
      // default module is registry.modules.first == mandelbrot.
      controller.updateParam('colorScheme', 1);
      controller.randomizeParams(animate: false);

      final iterations = controller.params['iterations'];
      final bailout = controller.params['bailout'];
      final colorScheme = controller.params['colorScheme'];
      final iterationsParam =
          controller.module.parameters.firstWhere((p) => p.id == 'iterations');

      expect(iterations, isA<int>());
      expect(
        iterations as int,
        inInclusiveRange(
          iterationsParam.min.round(),
          iterationsParam.max.round(),
        ),
      );

      expect(bailout, isA<double>());
      expect(bailout as double, inInclusiveRange(2.0, 50.0));
      // Mandelbrot bailout step is 0.1; randomize snaps to step.
      final snapped = ((bailout * 10).round() / 10);
      expect(bailout, closeTo(snapped, 1e-9));

      expect(colorScheme, 1);
    });

    test('randomizeParams randomizes color count', () {
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      controller.selectModule(registry.byId('mandelbrot_tex'), animate: false);
      controller.updateParam('colorCount', 64);

      controller.randomizeParams(animate: false, random: Random(1));

      expect(controller.params['colorCount'], isA<int>());
      expect(controller.params['colorCount'], inInclusiveRange(2, 64));
      expect(controller.params['colorCount'], isNot(64));
    });

    test('randomizeParams lerps numeric params before final target', () async {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);
      controller.updateParam('iterations', 20);
      final start = controller.params['iterations'];

      controller.randomizeParams(random: Random(1));
      await Future<void>.delayed(const Duration(milliseconds: 180));
      final mid = controller.params['iterations'];
      await Future<void>.delayed(const Duration(milliseconds: 650));
      final end = controller.params['iterations'];

      expect(mid, isNot(start));
      expect(end, isNot(start));
      expect(mid, isNot(end));
    });

    test('selectModule can reset view atomically without zoom-out flash', () {
      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      final target = registry.modules.firstWhere(
        (module) =>
            module.id != controller.module.id &&
            (module.defaultPreset.view.zoom - 1.0).abs() > 0.001,
      );
      final notifiedZooms = <double>[];
      controller
        ..updateZoom(2.0)
        ..addListener(() => notifiedZooms.add(controller.view.zoom));

      controller.selectModule(target, animate: false, resetView: true);

      expect(controller.module.id, target.id);
      expect(controller.view.zoom, 1.0);
      expect(notifiedZooms, [1.0]);
    });

    test('updateZoom adaptively increases iterations when zooming in', () {
      final controller = FractalController(ModuleRegistry());
      final startZoom = controller.view.zoom;
      final startIterations = controller.params['iterations'] as int;
      final iterationsParam =
          controller.module.parameters.firstWhere((p) => p.id == 'iterations');

      controller.updateZoom(startZoom * 2.0);
      final afterZoom2 = controller.params['iterations'] as int;

      controller.updateZoom(startZoom * 32.0);
      final afterZoom32 = controller.params['iterations'] as int;

      controller.updateZoom(startZoom);
      final afterZoomOut = controller.params['iterations'] as int;

      expect(afterZoom2, greaterThan(startIterations));
      expect(afterZoom32, greaterThan(afterZoom2));
      expect(
        afterZoom32,
        inInclusiveRange(
          iterationsParam.min.round(),
          iterationsParam.max.round(),
        ),
      );
      // Adaptive policy only raises while zooming in; zooming out keeps budget.
      expect(afterZoomOut, afterZoom32);
    });
  });
}
