// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0576_mandelbox_s_3_0/f0576_mandelbox_s_3_0_module.dart';

void main() {
  test('F0576MandelboxS30 instantiates', () {
    final m = F0576MandelboxS30();
    expect(m.id, 'f0576_mandelbox_s_3_0');
    expect(m.shader, 'shaders/f0576_mandelbox_s_3_0_gpu.frag');
  });

  test('F0576MandelboxS30 presets are well-formed', () {
    final m = F0576MandelboxS30();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0576MandelboxS30 metadata is consistent', () {
    final m = F0576MandelboxS30();
    expect(m.metadata.id, m.id);
  });
}
