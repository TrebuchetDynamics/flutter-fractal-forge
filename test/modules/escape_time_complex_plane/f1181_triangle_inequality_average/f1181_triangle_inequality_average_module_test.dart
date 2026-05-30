// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1181_triangle_inequality_average/f1181_triangle_inequality_average_module.dart';

void main() {
  test('F1181TriangleInequalityAverage instantiates', () {
    final m = F1181TriangleInequalityAverage();
    expect(m.id, 'f1181_triangle_inequality_average');
    expect(m.shader, 'shaders/f1181_triangle_inequality_average_gpu.frag');
  });

  test('F1181TriangleInequalityAverage presets are well-formed', () {
    final m = F1181TriangleInequalityAverage();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1181TriangleInequalityAverage metadata is consistent', () {
    final m = F1181TriangleInequalityAverage();
    expect(m.metadata.id, m.id);
  });
}
