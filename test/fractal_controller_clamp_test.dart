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

    expect(controller.params['iterations'], 5000);
    expect(controller.params['bailout'], 50.0);
    // Enumeration invalid -> default for module.
    expect(controller.params['colorScheme'], 0);
  });
}
