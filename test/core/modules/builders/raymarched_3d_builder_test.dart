import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_builder.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_catalog.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';

void main() {
  group('buildRaymarched3DModule', () {
    test('curated extra presets are normalized as replayable built-ins', () {
      final config = Raymarched3DConfig(
        id: 'ray-curated-test',
        name: 'Ray Curated Test',
        shaderAsset: 'shaders/ray_curated_test.frag',
        extraPresets: [
          FractalPreset(
            id: 'ray-curated-test-interesting',
            moduleId: 'ray-curated-test',
            name: 'Interesting',
            params: const {'power': 8.0, 'iterations': 40},
            view: FractalViewState(
              pan: Vector2.zero(),
              zoom: 1.5,
              rotation: Vector3(0.2, 0.3, 0.4),
            ),
            createdAt: DateTime.now(),
          ),
        ],
      );

      final module = buildRaymarched3DModule(config);
      final curated = module.builtInPresets.singleWhere(
        (preset) => preset.id == 'ray-curated-test-interesting',
      );

      expect(curated.isBuiltIn, isTrue);
      expect(curated.createdAt, DateTime.utc(2025, 1, 1));
      expect(curated.params['power'], 8.0);
      expect(curated.view.zoom, 1.5);
    });

    test('curated extra preset moduleIds are normalized to module id', () {
      final config = Raymarched3DConfig(
        id: 'ray-module-id-test',
        name: 'Ray Module Id Test',
        shaderAsset: 'shaders/ray_module_id_test.frag',
        extraPresets: [
          FractalPreset(
            id: 'ray-module-id-test-interesting',
            moduleId: 'stale-ray-module-id',
            name: 'Interesting',
            params: const {'power': 8.0, 'iterations': 40},
            view: FractalViewState(
              pan: Vector2.zero(),
              zoom: 1.5,
              rotation: Vector3(0.2, 0.3, 0.4),
            ),
            createdAt: DateTime.now(),
          ),
        ],
      );

      final module = buildRaymarched3DModule(config);

      expect(
        module.builtInPresets.map((preset) => preset.moduleId),
        everyElement('ray-module-id-test'),
      );
    });

    test('declared extra shader parameters are part of the module defaults',
        () {
      final config = Raymarched3DConfig(
        id: 'ray-extra-parameter-test',
        name: 'Ray Extra Parameter Test',
        shaderAsset: 'shaders/ray_extra_parameter_test.frag',
        extraParams: [
          FractalParameter(
            id: 'seed',
            label: (_) => 'Random Seed',
            type: FractalParamType.integer,
            min: 0,
            max: 9999,
            step: 1,
            defaultValue: 37,
          ),
        ],
      );

      final module = buildRaymarched3DModule(config);

      expect(
          module.parameters.map((parameter) => parameter.id), contains('seed'));
      expect(module.defaultPreset.params['seed'], 37);
      expect(Raymarched3DUniformSlots.extraStart, 16);
    });

    test('catalog modules expose unique built-in preset ids', () {
      for (final config in raymarched3DCatalog) {
        final module = buildRaymarched3DModule(config);
        final ids = module.builtInPresets.map((preset) => preset.id).toList();

        expect(ids.toSet(), hasLength(ids.length), reason: module.id);
      }
    });
  });
}
