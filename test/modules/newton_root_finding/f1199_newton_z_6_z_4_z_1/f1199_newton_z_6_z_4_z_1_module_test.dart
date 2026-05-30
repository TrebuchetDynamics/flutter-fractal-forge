// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1199_newton_z_6_z_4_z_1/f1199_newton_z_6_z_4_z_1_module.dart';

void main() {
  test('F1199NewtonZ6Z4Z1 instantiates', () {
    final m = F1199NewtonZ6Z4Z1();
    expect(m.id, 'f1199_newton_z_6_z_4_z_1');
    expect(m.shader, 'shaders/f1199_newton_z_6_z_4_z_1_gpu.frag');
  });

  test('F1199NewtonZ6Z4Z1 presets are well-formed', () {
    final m = F1199NewtonZ6Z4Z1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1199NewtonZ6Z4Z1 metadata is consistent', () {
    final m = F1199NewtonZ6Z4Z1();
    expect(m.metadata.id, m.id);
  });
}
