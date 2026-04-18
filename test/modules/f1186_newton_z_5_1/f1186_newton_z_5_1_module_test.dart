// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1186_newton_z_5_1/f1186_newton_z_5_1_module.dart';

void main() {
  test('F1186NewtonZ51 instantiates', () {
    final m = F1186NewtonZ51();
    expect(m.id, 'f1186_newton_z_5_1');
    expect(m.shader, 'shaders/f1186_newton_z_5_1_gpu.frag');
  });

  test('F1186NewtonZ51 presets are well-formed', () {
    final m = F1186NewtonZ51();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1186NewtonZ51 metadata is consistent', () {
    final m = F1186NewtonZ51();
    expect(m.metadata.id, m.id);
  });
}
