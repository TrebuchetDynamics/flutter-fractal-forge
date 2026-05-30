// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0050_r_ssler_attractor/f0050_r_ssler_attractor_module.dart';

void main() {
  test('F0050RSslerAttractor instantiates', () {
    final m = F0050RSslerAttractor();
    expect(m.id, 'f0050_r_ssler_attractor');
    expect(m.shader, 'shaders/f0050_r_ssler_attractor_gpu.frag');
  });

  test('F0050RSslerAttractor presets are well-formed', () {
    final m = F0050RSslerAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0050RSslerAttractor metadata is consistent', () {
    final m = F0050RSslerAttractor();
    expect(m.metadata.id, m.id);
  });
}
