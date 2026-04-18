// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1203_newton_tan_z_z/f1203_newton_tan_z_z_module.dart';

void main() {
  test('F1203NewtonTanZZ instantiates', () {
    final m = F1203NewtonTanZZ();
    expect(m.id, 'f1203_newton_tan_z_z');
    expect(m.shader, 'shaders/f1203_newton_tan_z_z_gpu.frag');
  });

  test('F1203NewtonTanZZ presets are well-formed', () {
    final m = F1203NewtonTanZZ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1203NewtonTanZZ metadata is consistent', () {
    final m = F1203NewtonTanZZ();
    expect(m.metadata.id, m.id);
  });
}
