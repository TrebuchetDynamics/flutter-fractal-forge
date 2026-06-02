import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_builder.dart';

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
  });
}
