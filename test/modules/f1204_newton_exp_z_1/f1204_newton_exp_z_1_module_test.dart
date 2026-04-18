// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1204_newton_exp_z_1/f1204_newton_exp_z_1_module.dart';

void main() {
  test('F1204NewtonExpZ1 instantiates', () {
    final m = F1204NewtonExpZ1();
    expect(m.id, 'f1204_newton_exp_z_1');
    expect(m.shader, 'shaders/f1204_newton_exp_z_1_gpu.frag');
  });

  test('F1204NewtonExpZ1 presets are well-formed', () {
    final m = F1204NewtonExpZ1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1204NewtonExpZ1 metadata is consistent', () {
    final m = F1204NewtonExpZ1();
    expect(m.metadata.id, m.id);
  });
}
