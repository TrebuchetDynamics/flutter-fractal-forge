// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0028_sprott_o/f0028_sprott_o_module.dart';

void main() {
  test('F0028SprottO instantiates', () {
    final m = F0028SprottO();
    expect(m.id, 'f0028_sprott_o');
    expect(m.shader, 'shaders/f0028_sprott_o_gpu.frag');
  });

  test('F0028SprottO presets are well-formed', () {
    final m = F0028SprottO();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0028SprottO metadata is consistent', () {
    final m = F0028SprottO();
    expect(m.metadata.id, m.id);
  });
}
