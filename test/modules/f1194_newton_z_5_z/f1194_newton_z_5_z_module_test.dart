// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1194_newton_z_5_z/f1194_newton_z_5_z_module.dart';

void main() {
  test('F1194NewtonZ5Z instantiates', () {
    final m = F1194NewtonZ5Z();
    expect(m.id, 'f1194_newton_z_5_z');
    expect(m.shader, 'shaders/f1194_newton_z_5_z_gpu.frag');
  });

  test('F1194NewtonZ5Z presets are well-formed', () {
    final m = F1194NewtonZ5Z();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1194NewtonZ5Z metadata is consistent', () {
    final m = F1194NewtonZ5Z();
    expect(m.metadata.id, m.id);
  });
}
