// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1191_newton_z_12_1/f1191_newton_z_12_1_module.dart';

void main() {
  test('F1191NewtonZ121 instantiates', () {
    final m = F1191NewtonZ121();
    expect(m.id, 'f1191_newton_z_12_1');
    expect(m.shader, 'shaders/f1191_newton_z_12_1_gpu.frag');
  });

  test('F1191NewtonZ121 presets are well-formed', () {
    final m = F1191NewtonZ121();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1191NewtonZ121 metadata is consistent', () {
    final m = F1191NewtonZ121();
    expect(m.metadata.id, m.id);
  });
}
