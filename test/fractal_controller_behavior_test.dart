import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FractalController', () {
    test('updateZoom clamps to [0.05, 20.0]', () {
      final controller = FractalController(ModuleRegistry());

      controller.updateZoom(0.0001);
      expect(controller.view.zoom, 0.05);

      controller.updateZoom(999);
      expect(controller.view.zoom, 20.0);

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

      expect(iterations, isA<int>());
      expect(iterations as int, inInclusiveRange(20, 500));

      expect(bailout, isA<double>());
      expect(bailout as double, inInclusiveRange(2.0, 8.0));
      // Mandelbrot bailout step is 0.1; randomize snaps to step.
      final snapped = ((bailout * 10).round() / 10);
      expect(bailout, closeTo(snapped, 1e-9));

      expect(colorScheme, isA<int>());
      expect(colorScheme as int, inInclusiveRange(0, 63));
    });

    test('applyArQualityPreset updates known params and clamps to schema', () {
      final controller = FractalController(ModuleRegistry());
      // Force a clearly out-of-range value that should be clamped after applying.
      controller.updateParam('iterations', 9999);
      expect(controller.params['iterations'], 500);

      controller.applyArQualityPreset(ArQualityPreset.high);
      // For mandelbrot, high -> iterations 220 (within [20,500]).
      expect(controller.params['iterations'], 220);

      // If we switch to a module without AR overrides, it should do nothing.
      controller.selectModule(controller.registry.byId('julia'));
      final before = Map<String, Object>.from(controller.params);
      controller.applyArQualityPreset(ArQualityPreset.high);
      expect(controller.params, before);
    });
  });
}
