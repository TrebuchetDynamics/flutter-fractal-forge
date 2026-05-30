// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1202_newton_cos_z/f1202_newton_cos_z_module.dart';

void main() {
  test('F1202NewtonCosZ instantiates', () {
    final m = F1202NewtonCosZ();
    expect(m.id, 'f1202_newton_cos_z');
    expect(m.shader, 'shaders/f1202_newton_cos_z_gpu.frag');
  });

  test('F1202NewtonCosZ presets are well-formed', () {
    final m = F1202NewtonCosZ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1202NewtonCosZ metadata is consistent', () {
    final m = F1202NewtonCosZ();
    expect(m.metadata.id, m.id);
  });
}
