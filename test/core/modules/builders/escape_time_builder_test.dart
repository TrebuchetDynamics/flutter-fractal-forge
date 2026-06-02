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

    test('curated extra preset moduleIds are normalized to module id', () {
      final config = EscapeTimeConfig(
        id: 'module-id-test',
        name: 'Module Id Test',
        shaderAsset: 'shaders/module_id_test.frag',
        extraPresets: [
          FractalPreset(
            id: 'module-id-test-interesting',
            moduleId: 'stale-module-id',
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

      expect(
        module.builtInPresets.map((preset) => preset.moduleId),
        everyElement('module-id-test'),
      );
    });

    test('curated preset ids cannot collide with generated classic ids', () {
      final config = EscapeTimeConfig(
        id: 'collision-test',
        name: 'Collision Test',
        shaderAsset: 'shaders/collision_test.frag',
        extraPresets: [
          FractalPreset(
            id: 'collision-test-classic',
            moduleId: 'collision-test',
            name: 'Curated Classic',
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
      final ids = module.builtInPresets.map((preset) => preset.id).toList();

      expect(ids, ['collision-test-classic', 'collision-test-classic-2']);
      expect(ids.toSet(), hasLength(ids.length));
      expect(module.builtInPresets.last.name, 'Curated Classic');
    });
  });
}
