import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FractalPreset JSON', () {
    test('toJson/fromJson round-trips core fields', () {
      final preset = FractalPreset(
        id: 'p1',
        moduleId: 'mandelbrot',
        name: 'Test',
        params: const {
          'iterations': 123,
          'bailout': 4.5,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2(1.25, -3.5),
          zoom: 2.0,
          rotation: Vector3(0.1, 0.2, 0.3),
        ),
        createdAt: DateTime(2026, 1, 2, 3, 4, 5),
        isBuiltIn: true,
        thumbnailPath: 'thumb.png',
      );

      final decoded = FractalPreset.fromJson(preset.toJson());

      expect(decoded.id, preset.id);
      expect(decoded.moduleId, preset.moduleId);
      expect(decoded.name, preset.name);
      expect(decoded.params, preset.params);
      expect(decoded.isBuiltIn, isTrue);
      expect(decoded.thumbnailPath, 'thumb.png');
      expect(decoded.view.pan.x, closeTo(1.25, 1e-9));
      expect(decoded.view.pan.y, closeTo(-3.5, 1e-9));
      expect(decoded.view.zoom, closeTo(2.0, 1e-9));
      expect(decoded.view.rotation.x, closeTo(0.1, 1e-9));
      expect(decoded.view.rotation.y, closeTo(0.2, 1e-9));
      expect(decoded.view.rotation.z, closeTo(0.3, 1e-9));
      expect(decoded.createdAt.toIso8601String(), preset.createdAt.toIso8601String());
    });

    test('fromJson tolerates missing view fields and invalid createdAt', () {
      final decoded = FractalPreset.fromJson({
        'id': 'p2',
        'moduleId': 'mandelbrot',
        'name': 'Broken',
        'params': <String, Object>{'iterations': 1},
        // view intentionally omitted
        'createdAt': 'not-a-date',
      });

      expect(decoded.view.zoom, 1.0);
      expect(decoded.view.pan, equals(Vector2.zero()));
      expect(decoded.view.rotation, equals(Vector3.zero()));
      // Should fall back to "now" and not throw.
      expect(decoded.createdAt, isA<DateTime>());
    });

    test('listToPrefs/listFromPrefs round-trip and handle empty payload', () {
      expect(FractalPreset.listFromPrefs(null), isEmpty);
      expect(FractalPreset.listFromPrefs(''), isEmpty);

      final presets = [
        FractalPreset(
          id: 'a',
          moduleId: 'mandelbrot',
          name: 'A',
          params: const {'iterations': 120},
          view: FractalViewState.initial(),
          createdAt: DateTime(2026, 1, 1),
        ),
        FractalPreset(
          id: 'b',
          moduleId: 'mandelbrot',
          name: 'B',
          params: const {'iterations': 200},
          view: FractalViewState.initial(),
          createdAt: DateTime(2026, 1, 2),
        ),
      ];

      final payload = FractalPreset.listToPrefs(presets);
      final decoded = FractalPreset.listFromPrefs(payload);

      expect(decoded.map((p) => p.id).toList(), ['a', 'b']);
      expect(decoded[1].params['iterations'], 200);
    });
  });
}
