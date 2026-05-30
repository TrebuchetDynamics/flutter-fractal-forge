// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0573_mandelbox_s_2_2/f0573_mandelbox_s_2_2_module.dart';

void main() {
  test('F0573MandelboxS22 instantiates', () {
    final m = F0573MandelboxS22();
    expect(m.id, 'f0573_mandelbox_s_2_2');
    expect(m.shader, 'shaders/f0573_mandelbox_s_2_2_gpu.frag');
  });

  test('F0573MandelboxS22 presets are well-formed', () {
    final m = F0573MandelboxS22();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0573MandelboxS22 metadata is consistent', () {
    final m = F0573MandelboxS22();
    expect(m.metadata.id, m.id);
  });
}
