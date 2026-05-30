// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1189_newton_z_8_1/f1189_newton_z_8_1_module.dart';

void main() {
  test('F1189NewtonZ81 instantiates', () {
    final m = F1189NewtonZ81();
    expect(m.id, 'f1189_newton_z_8_1');
    expect(m.shader, 'shaders/f1189_newton_z_8_1_gpu.frag');
  });

  test('F1189NewtonZ81 presets are well-formed', () {
    final m = F1189NewtonZ81();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1189NewtonZ81 metadata is consistent', () {
    final m = F1189NewtonZ81();
    expect(m.metadata.id, m.id);
  });
}
