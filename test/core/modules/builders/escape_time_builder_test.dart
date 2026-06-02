import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

void main() {
  group('buildEscapeTimeModule', () {
    test('built-in generated presets are replayable', () {
      const config = EscapeTimeConfig(
        id: 'replayable-test',
        name: 'Replayable Test',
        shaderAsset: 'shaders/replayable_test.frag',
      );

      final first = buildEscapeTimeModule(config);
      final second = buildEscapeTimeModule(config);

      expect(first.defaultPreset.createdAt, DateTime.utc(2025, 1, 1));
      expect(second.defaultPreset.createdAt, first.defaultPreset.createdAt);
      expect(
        first.builtInPresets.map((preset) => preset.createdAt),
        everyElement(first.defaultPreset.createdAt),
      );
      expect(
        first.builtInPresets.map((preset) => preset.isBuiltIn),
        everyElement(isTrue),
      );
    });

    test('curated extra presets are normalized as replayable built-ins', () {
      final config = EscapeTimeConfig(
        id: 'curated-test',
        name: 'Curated Test',
        shaderAsset: 'shaders/curated_test.frag',
        extraPresets: [
          FractalPreset(
            id: 'curated-test-interesting',
            moduleId: 'curated-test',
            name: 'Interesting',
            params: const {'iterations': 240, 'bailout': 4.0},
            view: FractalViewState(
              pan: Vector2(-0.75, 0.1),
              zoom: 8.0,
              rotation: Vector3.zero(),
            ),
            createdAt: DateTime.now(),
          ),
        ],
      );

      final module = buildEscapeTimeModule(config);
      final curated = module.builtInPresets.singleWhere(
        (preset) => preset.id == 'curated-test-interesting',
      );

      expect(curated.isBuiltIn, isTrue);
      expect(curated.createdAt, DateTime.utc(2025, 1, 1));
      expect(curated.params['iterations'], 240);
      expect(curated.view.zoom, 8.0);
    });
  });
}
