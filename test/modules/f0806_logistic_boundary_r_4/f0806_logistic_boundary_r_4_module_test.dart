// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0806_logistic_boundary_r_4/f0806_logistic_boundary_r_4_module.dart';

void main() {
  test('F0806LogisticBoundaryR4 instantiates', () {
    final m = F0806LogisticBoundaryR4();
    expect(m.id, 'f0806_logistic_boundary_r_4');
    expect(m.shader, 'shaders/f0806_logistic_boundary_r_4_gpu.frag');
  });

  test('F0806LogisticBoundaryR4 presets are well-formed', () {
    final m = F0806LogisticBoundaryR4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0806LogisticBoundaryR4 metadata is consistent', () {
    final m = F0806LogisticBoundaryR4();
    expect(m.metadata.id, m.id);
  });
}
