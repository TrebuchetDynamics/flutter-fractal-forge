// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0572_mandelbox_s_2_0/f0572_mandelbox_s_2_0_module.dart';

void main() {
  test('F0572MandelboxS20 instantiates', () {
    final m = F0572MandelboxS20();
    expect(m.id, 'f0572_mandelbox_s_2_0');
    expect(m.shader, 'shaders/f0572_mandelbox_s_2_0_gpu.frag');
  });

  test('F0572MandelboxS20 presets are well-formed', () {
    final m = F0572MandelboxS20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0572MandelboxS20 metadata is consistent', () {
    final m = F0572MandelboxS20();
    expect(m.metadata.id, m.id);
  });
}
