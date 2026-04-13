// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0031_sprott_r/f0031_sprott_r_module.dart';

void main() {
  test('F0031SprottR instantiates', () {
    final m = F0031SprottR();
    expect(m.id, 'f0031_sprott_r');
    expect(m.shader, 'shaders/f0031_sprott_r_gpu.frag');
  });

  test('F0031SprottR presets are well-formed', () {
    final m = F0031SprottR();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0031SprottR metadata is consistent', () {
    final m = F0031SprottR();
    expect(m.metadata.id, m.id);
  });
}
