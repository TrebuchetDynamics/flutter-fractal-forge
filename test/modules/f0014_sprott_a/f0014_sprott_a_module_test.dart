// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0014_sprott_a/f0014_sprott_a_module.dart';

void main() {
  test('F0014SprottA instantiates', () {
    final m = F0014SprottA();
    expect(m.id, 'f0014_sprott_a');
    expect(m.shader, 'shaders/f0014_sprott_a_gpu.frag');
  });

  test('F0014SprottA presets are well-formed', () {
    final m = F0014SprottA();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0014SprottA metadata is consistent', () {
    final m = F0014SprottA();
    expect(m.metadata.id, m.id);
  });
}
