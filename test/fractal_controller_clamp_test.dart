import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('FractalController clamps preset values to schema', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    final registry = ModuleRegistry();
    final controller = FractalController(registry);

    final badPreset = FractalPreset(
      id: 'bad',
      moduleId: controller.module.id,
      name: 'Bad',
      params: const {
        'iterations': 9999,
        'bailout': 9999.0,
        'colorScheme': 999,
      },
      view: FractalViewState(
        pan: Vector2(10, 20),
        zoom: 2.0,
        rotation: Vector3.zero(),
      ),
      createdAt: DateTime(2026, 1, 1),
    );

    controller.applyPreset(badPreset);

    final iterationsParam =
        controller.module.parameters.firstWhere((p) => p.id == 'iterations');
    final bailoutParam =
        controller.module.parameters.firstWhere((p) => p.id == 'bailout');

    expect(controller.params['iterations'], iterationsParam.max.round());
    expect(controller.params['bailout'], bailoutParam.max);
    // Enumeration invalid -> default for module.
    expect(controller.params['colorScheme'], 0);
  });

  test('FractalController sanitizes non-finite preset and loaded views', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    final registry = ModuleRegistry();
    final controller = FractalController(registry);

    controller.updateZoom(2.0);
    controller.updatePan(Vector2(0.5, -0.5));

    final badPreset = FractalPreset(
      id: 'bad-view',
      moduleId: controller.module.id,
      name: 'Bad view',
      params: const {},
      view: FractalViewState(
        pan: Vector2(double.nan, double.infinity),
        zoom: double.nan,
        rotation: Vector3.zero(),
      ),
      createdAt: DateTime(2026, 1, 1),
    );

    controller.applyPreset(badPreset);

    expect(controller.view.zoom, 2.0);
    expect(controller.view.pan.x, 0.5);
    expect(controller.view.pan.y, 3.0);

    controller.loadState(
      params: const {},
      view: FractalViewState(
        pan: Vector2(double.negativeInfinity, double.nan),
        zoom: double.infinity,
        rotation: Vector3.zero(),
      ),
    );

    expect(controller.view.zoom, 1e12);
    expect(controller.view.pan.x, -3.0);
    expect(controller.view.pan.y, 3.0);
  });
}
