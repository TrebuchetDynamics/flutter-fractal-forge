// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0575_mandelbox_s_2_7/f0575_mandelbox_s_2_7_module.dart';

void main() {
  test('F0575MandelboxS27 instantiates', () {
    final m = F0575MandelboxS27();
    expect(m.id, 'f0575_mandelbox_s_2_7');
    expect(m.shader, 'shaders/f0575_mandelbox_s_2_7_gpu.frag');
  });

  test('F0575MandelboxS27 presets are well-formed', () {
    final m = F0575MandelboxS27();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0575MandelboxS27 metadata is consistent', () {
    final m = F0575MandelboxS27();
    expect(m.metadata.id, m.id);
  });
}
