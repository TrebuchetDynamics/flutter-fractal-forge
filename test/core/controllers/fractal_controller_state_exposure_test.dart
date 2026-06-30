import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FractalController state exposure', () {
    test('exposes params as a read-only snapshot', () {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);

      final initialIterations = controller.params['iterations'];
      final exposedParams = controller.params;

      expect(
        () => exposedParams['iterations'] = double.nan,
        throwsUnsupportedError,
      );
      expect(controller.params['iterations'], initialIterations);
    });

    test('exposes view vectors as snapshots instead of mutable state', () {
      final controller = FractalController(ModuleRegistry());
      addTearDown(controller.dispose);

      controller.updatePan(Vector2(0.25, -0.5));
      controller.updateRotation(Vector3(0.1, 0.2, 0.3));

      final exposedView = controller.view;
      exposedView.pan.setValues(2.0, 3.0);
      exposedView.rotation.setValues(4.0, 5.0, 6.0);

      expect(controller.view.pan, Vector2(0.25, -0.5));
      expect(controller.view.rotation, Vector3(0.1, 0.2, 0.3));

      final exposedAlias = controller.viewState;
      exposedAlias.pan.setValues(-2.0, -3.0);
      exposedAlias.rotation.setValues(-4.0, -5.0, -6.0);

      expect(controller.view.pan, Vector2(0.25, -0.5));
      expect(controller.view.rotation, Vector3(0.1, 0.2, 0.3));
    });
  });
}
