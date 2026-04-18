// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1187_newton_z_6_1/f1187_newton_z_6_1_module.dart';

void main() {
  test('F1187NewtonZ61 instantiates', () {
    final m = F1187NewtonZ61();
    expect(m.id, 'f1187_newton_z_6_1');
    expect(m.shader, 'shaders/f1187_newton_z_6_1_gpu.frag');
  });

  test('F1187NewtonZ61 presets are well-formed', () {
    final m = F1187NewtonZ61();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1187NewtonZ61 metadata is consistent', () {
    final m = F1187NewtonZ61();
    expect(m.metadata.id, m.id);
  });
}
