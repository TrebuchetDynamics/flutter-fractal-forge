import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
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

    test('applyArQualityPreset updates known params and clamps to schema', () {
      final controller = FractalController(ModuleRegistry());
      final iterationsParam =
          controller.module.parameters.firstWhere((p) => p.id == 'iterations');
      // Force a clearly out-of-range value that should be clamped after applying.
      controller.updateParam('iterations', 9999);
      expect(controller.params['iterations'], iterationsParam.max.round());

      controller.applyArQualityPreset(ArQualityPreset.high);
      // For mandelbrot, high -> iterations 220 (within [20,5000]).
      expect(controller.params['iterations'], 220);

      // Julia has AR overrides in this build; verify it updates safely.
      controller.selectModule(controller.registry.byId('julia'));
      controller.applyArQualityPreset(ArQualityPreset.high);
      expect(controller.params['iterations'], 200);
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
