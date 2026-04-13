// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0577_mandelbox_s_3_5/f0577_mandelbox_s_3_5_module.dart';

void main() {
  test('F0577MandelboxS35 instantiates', () {
    final m = F0577MandelboxS35();
    expect(m.id, 'f0577_mandelbox_s_3_5');
    expect(m.shader, 'shaders/f0577_mandelbox_s_3_5_gpu.frag');
  });

  test('F0577MandelboxS35 presets are well-formed', () {
    final m = F0577MandelboxS35();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0577MandelboxS35 metadata is consistent', () {
    final m = F0577MandelboxS35();
    expect(m.metadata.id, m.id);
  });
}
