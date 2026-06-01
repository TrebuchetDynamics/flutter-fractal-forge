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

    test('treats view changes as a different location', () {
      final first = _entry(zoom: 1);
      final second = _entry(zoom: 2);

      expect(first.isSameLocation(second), isFalse);
    });
  });
}
