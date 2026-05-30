// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1206_newton_z_3_1_relaxed_1_5/f1206_newton_z_3_1_relaxed_1_5_module.dart';

void main() {
  test('F1206NewtonZ31Relaxed15 instantiates', () {
    final m = F1206NewtonZ31Relaxed15();
    expect(m.id, 'f1206_newton_z_3_1_relaxed_1_5');
    expect(m.shader, 'shaders/f1206_newton_z_3_1_relaxed_1_5_gpu.frag');
  });

  test('F1206NewtonZ31Relaxed15 presets are well-formed', () {
    final m = F1206NewtonZ31Relaxed15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1206NewtonZ31Relaxed15 metadata is consistent', () {
    final m = F1206NewtonZ31Relaxed15();
    expect(m.metadata.id, m.id);
  });
}
