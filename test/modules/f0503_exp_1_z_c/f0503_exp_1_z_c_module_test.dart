// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0503_exp_1_z_c/f0503_exp_1_z_c_module.dart';

void main() {
  test('F0503Exp1ZC instantiates', () {
    final m = F0503Exp1ZC();
    expect(m.id, 'f0503_exp_1_z_c');
    expect(m.shader, 'shaders/f0503_exp_1_z_c_gpu.frag');
  });

  test('F0503Exp1ZC presets are well-formed', () {
    final m = F0503Exp1ZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0503Exp1ZC metadata is consistent', () {
    final m = F0503Exp1ZC();
    expect(m.metadata.id, m.id);
  });
}
