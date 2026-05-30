// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1197_newton_z_4_z/f1197_newton_z_4_z_module.dart';

void main() {
  test('F1197NewtonZ4Z instantiates', () {
    final m = F1197NewtonZ4Z();
    expect(m.id, 'f1197_newton_z_4_z');
    expect(m.shader, 'shaders/f1197_newton_z_4_z_gpu.frag');
  });

  test('F1197NewtonZ4Z presets are well-formed', () {
    final m = F1197NewtonZ4Z();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1197NewtonZ4Z metadata is consistent', () {
    final m = F1197NewtonZ4Z();
    expect(m.metadata.id, m.id);
  });
}
