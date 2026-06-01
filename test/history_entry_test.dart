import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:vector_math/vector_math.dart';

HistoryEntry _entry({
  String moduleId = 'mandelbrot',
  double zoom = 1,
  Map<String, Object> params = const <String, Object>{},
}) {
  return HistoryEntry(
    id: 'entry-$moduleId-$zoom-${params.length}',
    moduleId: moduleId,
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: zoom,
      rotation: Vector3.zero(),
    ),
    params: params,
    visitedAt: DateTime.utc(2024),
  );
}

void main() {
  group('HistoryEntry location identity', () {
    test('treats matching module, view, and params as the same location', () {
      final first = _entry(params: {'iterations': 100, 'bailout': 4.0});
      final second = _entry(params: {'bailout': 4.0, 'iterations': 100});

      expect(first.isSameLocation(second), isTrue);
    });

    test('treats parameter changes as a different location', () {
      final first = _entry(params: {'iterations': 100});
      final second = _entry(params: {'iterations': 250});

      expect(first.isSameLocation(second), isFalse);
    });

    test('treats JSON-like list parameter values as replayable values', () {
      final first = _entry(params: {
        'paletteStops': [0.0, 0.5, 1.0],
      });
      final second = _entry(params: {
        'paletteStops': [0.0, 0.5, 1.0],
      });

      expect(first.isSameLocation(second), isTrue);
    });

    test('treats view changes as a different location', () {
      final first = _entry(zoom: 1);
      final second = _entry(zoom: 2);

      expect(first.isSameLocation(second), isFalse);
    });

    test('snapshots mutable view vectors and params when created from state',
        () {
      final pan = Vector2(1, 2);
      final rotation = Vector3(3, 4, 5);
      final params = <String, Object>{'iterations': 100};
      final entry = HistoryEntry.fromState(
        moduleId: 'mandelbrot',
        view: FractalViewState(pan: pan, zoom: 6, rotation: rotation),
        params: params,
      );

      pan.setValues(7, 8);
      rotation.setValues(9, 10, 11);
      params['iterations'] = 250;

      expect(entry.view.pan.x, 1);
      expect(entry.view.pan.y, 2);
      expect(entry.view.rotation.x, 3);
      expect(entry.view.rotation.y, 4);
      expect(entry.view.rotation.z, 5);
      expect(entry.params, {'iterations': 100});
    });

    test('serializes nested map parameter keys as JSON object keys', () {
      final entry = HistoryEntry.fromState(
        moduleId: 'mandelbrot',
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 6,
          rotation: Vector3.zero(),
        ),
        params: <String, Object>{
          'metadata': <Object, Object>{1: 'one'},
        },
      );

      final encoded = jsonEncode(entry.toJson());
      final decoded = jsonDecode(encoded) as Map<String, Object?>;
      final restored = HistoryEntry.fromJson(decoded);

      expect(restored.params, {
        'metadata': {'1': 'one'},
      });
    });

    test('deep-snapshots nested JSON-like params when created from state', () {
      final paletteStops = <Object?>[
        0.0,
        <String, Object?>{
          'position': 0.5,
          'rgb': <Object?>[32, 64, 128],
        },
        1.0,
      ];
      final params = <String, Object>{'paletteStops': paletteStops};

      final entry = HistoryEntry.fromState(
        moduleId: 'mandelbrot',
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 6,
          rotation: Vector3.zero(),
        ),
        params: params,
      );

      (paletteStops[1] as Map<String, Object?>)['position'] = 0.75;
      ((paletteStops[1] as Map<String, Object?>)['rgb'] as List<Object?>)[0] =
          255;
      paletteStops.add(2.0);

      expect(entry.params, {
        'paletteStops': [
          0.0,
          {
            'position': 0.5,
            'rgb': [32, 64, 128],
          },
          1.0,
        ],
      });
    });
  });
}
