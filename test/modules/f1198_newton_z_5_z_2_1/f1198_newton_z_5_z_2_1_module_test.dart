// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1198_newton_z_5_z_2_1/f1198_newton_z_5_z_2_1_module.dart';

void main() {
  test('F1198NewtonZ5Z21 instantiates', () {
    final m = F1198NewtonZ5Z21();
    expect(m.id, 'f1198_newton_z_5_z_2_1');
    expect(m.shader, 'shaders/f1198_newton_z_5_z_2_1_gpu.frag');
  });

  test('F1198NewtonZ5Z21 presets are well-formed', () {
    final m = F1198NewtonZ5Z21();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1198NewtonZ5Z21 metadata is consistent', () {
    final m = F1198NewtonZ5Z21();
    expect(m.metadata.id, m.id);
  });
}
