// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1200_newton_z_4_z_3_2/f1200_newton_z_4_z_3_2_module.dart';

void main() {
  test('F1200NewtonZ4Z32 instantiates', () {
    final m = F1200NewtonZ4Z32();
    expect(m.id, 'f1200_newton_z_4_z_3_2');
    expect(m.shader, 'shaders/f1200_newton_z_4_z_3_2_gpu.frag');
  });

  test('F1200NewtonZ4Z32 presets are well-formed', () {
    final m = F1200NewtonZ4Z32();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1200NewtonZ4Z32 metadata is consistent', () {
    final m = F1200NewtonZ4Z32();
    expect(m.metadata.id, m.id);
  });
}
