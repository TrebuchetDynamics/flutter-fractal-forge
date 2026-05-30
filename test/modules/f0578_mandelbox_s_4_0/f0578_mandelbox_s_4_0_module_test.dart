// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0578_mandelbox_s_4_0/f0578_mandelbox_s_4_0_module.dart';

void main() {
  test('F0578MandelboxS40 instantiates', () {
    final m = F0578MandelboxS40();
    expect(m.id, 'f0578_mandelbox_s_4_0');
    expect(m.shader, 'shaders/f0578_mandelbox_s_4_0_gpu.frag');
  });

  test('F0578MandelboxS40 presets are well-formed', () {
    final m = F0578MandelboxS40();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0578MandelboxS40 metadata is consistent', () {
    final m = F0578MandelboxS40();
    expect(m.metadata.id, m.id);
  });
}
