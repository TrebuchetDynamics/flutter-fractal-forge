// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1207_newton_z_3_1_relaxed_2_0/f1207_newton_z_3_1_relaxed_2_0_module.dart';

void main() {
  test('F1207NewtonZ31Relaxed20 instantiates', () {
    final m = F1207NewtonZ31Relaxed20();
    expect(m.id, 'f1207_newton_z_3_1_relaxed_2_0');
    expect(m.shader, 'shaders/f1207_newton_z_3_1_relaxed_2_0_gpu.frag');
  });

  test('F1207NewtonZ31Relaxed20 presets are well-formed', () {
    final m = F1207NewtonZ31Relaxed20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1207NewtonZ31Relaxed20 metadata is consistent', () {
    final m = F1207NewtonZ31Relaxed20();
    expect(m.metadata.id, m.id);
  });
}
