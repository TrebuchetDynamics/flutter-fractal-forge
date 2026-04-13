// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0582_mandelbox_s_3_0/f0582_mandelbox_s_3_0_module.dart';

void main() {
  test('F0582MandelboxS30 instantiates', () {
    final m = F0582MandelboxS30();
    expect(m.id, 'f0582_mandelbox_s_3_0');
    expect(m.shader, 'shaders/f0582_mandelbox_s_3_0_gpu.frag');
  });

  test('F0582MandelboxS30 presets are well-formed', () {
    final m = F0582MandelboxS30();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0582MandelboxS30 metadata is consistent', () {
    final m = F0582MandelboxS30();
    expect(m.metadata.id, m.id);
  });
}
