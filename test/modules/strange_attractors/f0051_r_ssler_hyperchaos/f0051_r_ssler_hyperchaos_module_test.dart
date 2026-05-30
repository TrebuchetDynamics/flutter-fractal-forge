// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0051_r_ssler_hyperchaos/f0051_r_ssler_hyperchaos_module.dart';

void main() {
  test('F0051RSslerHyperchaos instantiates', () {
    final m = F0051RSslerHyperchaos();
    expect(m.id, 'f0051_r_ssler_hyperchaos');
    expect(m.shader, 'shaders/f0051_r_ssler_hyperchaos_gpu.frag');
  });

  test('F0051RSslerHyperchaos presets are well-formed', () {
    final m = F0051RSslerHyperchaos();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0051RSslerHyperchaos metadata is consistent', () {
    final m = F0051RSslerHyperchaos();
    expect(m.metadata.id, m.id);
  });
}
