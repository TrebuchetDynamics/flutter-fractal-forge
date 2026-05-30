// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0574_mandelbox_s_2_5/f0574_mandelbox_s_2_5_module.dart';

void main() {
  test('F0574MandelboxS25 instantiates', () {
    final m = F0574MandelboxS25();
    expect(m.id, 'f0574_mandelbox_s_2_5');
    expect(m.shader, 'shaders/f0574_mandelbox_s_2_5_gpu.frag');
  });

  test('F0574MandelboxS25 presets are well-formed', () {
    final m = F0574MandelboxS25();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0574MandelboxS25 metadata is consistent', () {
    final m = F0574MandelboxS25();
    expect(m.metadata.id, m.id);
  });
}
