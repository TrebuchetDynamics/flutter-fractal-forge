// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1205_newton_z_3_1_relaxed_0_5/f1205_newton_z_3_1_relaxed_0_5_module.dart';

void main() {
  test('F1205NewtonZ31Relaxed05 instantiates', () {
    final m = F1205NewtonZ31Relaxed05();
    expect(m.id, 'f1205_newton_z_3_1_relaxed_0_5');
    expect(m.shader, 'shaders/f1205_newton_z_3_1_relaxed_0_5_gpu.frag');
  });

  test('F1205NewtonZ31Relaxed05 presets are well-formed', () {
    final m = F1205NewtonZ31Relaxed05();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1205NewtonZ31Relaxed05 metadata is consistent', () {
    final m = F1205NewtonZ31Relaxed05();
    expect(m.metadata.id, m.id);
  });
}
