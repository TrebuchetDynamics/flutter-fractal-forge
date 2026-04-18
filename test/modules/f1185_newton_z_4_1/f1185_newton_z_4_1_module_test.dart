// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1185_newton_z_4_1/f1185_newton_z_4_1_module.dart';

void main() {
  test('F1185NewtonZ41 instantiates', () {
    final m = F1185NewtonZ41();
    expect(m.id, 'f1185_newton_z_4_1');
    expect(m.shader, 'shaders/f1185_newton_z_4_1_gpu.frag');
  });

  test('F1185NewtonZ41 presets are well-formed', () {
    final m = F1185NewtonZ41();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1185NewtonZ41 metadata is consistent', () {
    final m = F1185NewtonZ41();
    expect(m.metadata.id, m.id);
  });
}
