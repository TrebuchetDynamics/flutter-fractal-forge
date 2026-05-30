// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f1196_newton_z_3_2_z_2/f1196_newton_z_3_2_z_2_module.dart';

void main() {
  test('F1196NewtonZ32Z2 instantiates', () {
    final m = F1196NewtonZ32Z2();
    expect(m.id, 'f1196_newton_z_3_2_z_2');
    expect(m.shader, 'shaders/f1196_newton_z_3_2_z_2_gpu.frag');
  });

  test('F1196NewtonZ32Z2 presets are well-formed', () {
    final m = F1196NewtonZ32Z2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1196NewtonZ32Z2 metadata is consistent', () {
    final m = F1196NewtonZ32Z2();
    expect(m.metadata.id, m.id);
  });
}
