// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0571_mandelbox_s_1_8/f0571_mandelbox_s_1_8_module.dart';

void main() {
  test('F0571MandelboxS18 instantiates', () {
    final m = F0571MandelboxS18();
    expect(m.id, 'f0571_mandelbox_s_1_8');
    expect(m.shader, 'shaders/f0571_mandelbox_s_1_8_gpu.frag');
  });

  test('F0571MandelboxS18 presets are well-formed', () {
    final m = F0571MandelboxS18();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0571MandelboxS18 metadata is consistent', () {
    final m = F0571MandelboxS18();
    expect(m.metadata.id, m.id);
  });
}
