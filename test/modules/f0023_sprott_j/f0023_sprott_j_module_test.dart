// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0023_sprott_j/f0023_sprott_j_module.dart';

void main() {
  test('F0023SprottJ instantiates', () {
    final m = F0023SprottJ();
    expect(m.id, 'f0023_sprott_j');
    expect(m.shader, 'shaders/f0023_sprott_j_gpu.frag');
  });

  test('F0023SprottJ presets are well-formed', () {
    final m = F0023SprottJ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0023SprottJ metadata is consistent', () {
    final m = F0023SprottJ();
    expect(m.metadata.id, m.id);
  });
}
