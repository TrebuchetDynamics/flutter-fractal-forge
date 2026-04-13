// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0581_mandelbox_s_2_5/f0581_mandelbox_s_2_5_module.dart';

void main() {
  test('F0581MandelboxS25 instantiates', () {
    final m = F0581MandelboxS25();
    expect(m.id, 'f0581_mandelbox_s_2_5');
    expect(m.shader, 'shaders/f0581_mandelbox_s_2_5_gpu.frag');
  });

  test('F0581MandelboxS25 presets are well-formed', () {
    final m = F0581MandelboxS25();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0581MandelboxS25 metadata is consistent', () {
    final m = F0581MandelboxS25();
    expect(m.metadata.id, m.id);
  });
}
