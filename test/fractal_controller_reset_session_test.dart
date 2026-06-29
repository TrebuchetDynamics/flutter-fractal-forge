import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FractalController.resetParams preserves view while restoring defaults',
      () {
    final controller = FractalController(ModuleRegistry());
    final initialIterations = controller.params['iterations'];

    controller.updateParam('iterations', 500);
    controller.updateZoom(2.5);
    controller.updatePan(Vector2(1.0, -2.0));
    controller.updateRotation(Vector3(0.1, 0.2, 0.3));

    final viewBeforeReset = controller.view;

    controller.resetParams();

    expect(controller.params['iterations'], initialIterations);
    expect(controller.view.zoom, viewBeforeReset.zoom);
    expect(controller.view.pan, viewBeforeReset.pan);
    expect(controller.view.rotation, viewBeforeReset.rotation);
  });

  test('FractalController.resetSession resets params + view + transparency',
      () {
    final controller = FractalController(ModuleRegistry());
    final initialIterations = controller.params['iterations'];

    // Mutate away from defaults.
    controller.updateParam('iterations', 500);
    controller.updateZoom(2.5);
    controller.updatePan(Vector2(1.0, -2.0));
    controller.setTransparentBackground(true);

    expect(controller.params['iterations'], 500);
    expect(controller.view.zoom, 2.5);
    expect(controller.transparentBackground, isTrue);

    controller.resetSession();

    // Defaults for the initial module (mandelbrot).
    expect(controller.params['iterations'], initialIterations);
    expect(controller.view.zoom, 1.0);
    expect(controller.view.pan, Vector2.zero());
    expect(controller.transparentBackground, isFalse);
  });
}
