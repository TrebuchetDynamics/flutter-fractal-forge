import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
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
      controller.randomizeParams();

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

      expect(colorScheme, isA<int>());
      expect(colorScheme as int, inInclusiveRange(0, 63));
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
