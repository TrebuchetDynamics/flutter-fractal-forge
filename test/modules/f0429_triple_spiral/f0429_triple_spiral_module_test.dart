// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0429_triple_spiral/f0429_triple_spiral_module.dart';

void main() {
  test('F0429TripleSpiral instantiates', () {
    final m = F0429TripleSpiral();
    expect(m.id, 'f0429_triple_spiral');
    expect(m.shader, 'shaders/f0429_triple_spiral_gpu.frag');
  });

  test('F0429TripleSpiral presets are well-formed', () {
    final m = F0429TripleSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0429TripleSpiral metadata is consistent', () {
    final m = F0429TripleSpiral();
    expect(m.metadata.id, m.id);
  });
}
