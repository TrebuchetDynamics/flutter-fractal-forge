// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0759_ford_circles_apollonian/f0759_ford_circles_apollonian_module.dart';

void main() {
  test('F0759FordCirclesApollonian instantiates', () {
    final m = F0759FordCirclesApollonian();
    expect(m.id, 'f0759_ford_circles_apollonian');
    expect(m.shader, 'shaders/f0759_ford_circles_apollonian_gpu.frag');
  });

  test('F0759FordCirclesApollonian presets are well-formed', () {
    final m = F0759FordCirclesApollonian();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0759FordCirclesApollonian metadata is consistent', () {
    final m = F0759FordCirclesApollonian();
    expect(m.metadata.id, m.id);
  });
}
