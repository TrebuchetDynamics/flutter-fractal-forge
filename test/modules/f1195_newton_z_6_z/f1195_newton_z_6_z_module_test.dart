// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1195_newton_z_6_z/f1195_newton_z_6_z_module.dart';

void main() {
  test('F1195NewtonZ6Z instantiates', () {
    final m = F1195NewtonZ6Z();
    expect(m.id, 'f1195_newton_z_6_z');
    expect(m.shader, 'shaders/f1195_newton_z_6_z_gpu.frag');
  });

  test('F1195NewtonZ6Z presets are well-formed', () {
    final m = F1195NewtonZ6Z();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1195NewtonZ6Z metadata is consistent', () {
    final m = F1195NewtonZ6Z();
    expect(m.metadata.id, m.id);
  });
}
