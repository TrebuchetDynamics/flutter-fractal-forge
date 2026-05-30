// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0232_l_vy_c_curve/f0232_l_vy_c_curve_module.dart';

void main() {
  test('F0232LVyCCurve instantiates', () {
    final m = F0232LVyCCurve();
    expect(m.id, 'f0232_l_vy_c_curve');
    expect(m.shader, 'shaders/f0232_l_vy_c_curve_gpu.frag');
  });

  test('F0232LVyCCurve presets are well-formed', () {
    final m = F0232LVyCCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0232LVyCCurve metadata is consistent', () {
    final m = F0232LVyCCurve();
    expect(m.metadata.id, m.id);
  });
}
