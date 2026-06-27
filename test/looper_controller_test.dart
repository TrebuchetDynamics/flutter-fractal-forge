import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/looper/looper_controller.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('looper lerps camera and numeric parameters', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);

    fractal
      ..updateView(_view(x: 0, y: 0, zoom: 1))
      ..updateParam('bailout', 2.0)
      ..updateParam('iterations', 100)
      ..updateParam('colorScheme', 0);
    looper.setAFromCurrent();

    fractal
      ..updateView(_view(x: 2, y: 0, zoom: 100))
      ..updateParam('bailout', 6.0)
      ..updateParam('iterations', 200)
      ..updateParam('colorScheme', 10);
    looper.setBFromCurrent();

    final halfway = looper.plan!.stateAtPhase(0.25);

    expect(halfway.view.pan.x, closeTo(1, 1e-9));
    expect(halfway.view.zoom, closeTo(10, 1e-9));
    expect(halfway.params['bailout'], closeTo(4, 1e-9));
    expect(halfway.params['iterations'], 150);
    expect(halfway.params['colorScheme'], 5);

    looper.dispose();
    fractal.dispose();
  });

  test('looper supports more than A and B keyframes', () {
    final fractal = FractalController(ModuleRegistry());
    final looper = LooperController(controller: fractal);

    for (final x in [0.0, 1.0, 2.0]) {
      fractal.updateView(_view(x: x, y: 0, zoom: 1));
      looper.addPointFromCurrent();
    }

    final plan = looper.plan!;

    expect(looper.points.length, 3);
    expect(plan.stateAtPhase(0).view.pan.x, closeTo(0, 1e-9));
    expect(plan.stateAtPhase(1 / 3).view.pan.x, closeTo(1, 1e-9));
    expect(plan.stateAtPhase(2 / 3).view.pan.x, closeTo(2, 1e-9));
    expect(plan.stateAtPhase(5 / 6).view.pan.x, closeTo(1, 1e-9));

    looper.dispose();
    fractal.dispose();
  });
}

FractalViewState _view({
  required double x,
  required double y,
  required double zoom,
}) =>
    FractalViewState(
      pan: Vector2(x, y),
      zoom: zoom,
      rotation: Vector3.zero(),
    );
