// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1190_newton_z_11_1/f1190_newton_z_11_1_module.dart';

void main() {
  test('F1190NewtonZ111 instantiates', () {
    final m = F1190NewtonZ111();
    expect(m.id, 'f1190_newton_z_11_1');
    expect(m.shader, 'shaders/f1190_newton_z_11_1_gpu.frag');
  });

  test('F1190NewtonZ111 presets are well-formed', () {
    final m = F1190NewtonZ111();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1190NewtonZ111 metadata is consistent', () {
    final m = F1190NewtonZ111();
    expect(m.metadata.id, m.id);
  });
}
