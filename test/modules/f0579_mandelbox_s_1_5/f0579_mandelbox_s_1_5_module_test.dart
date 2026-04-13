// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0579_mandelbox_s_1_5/f0579_mandelbox_s_1_5_module.dart';

void main() {
  test('F0579MandelboxS15 instantiates', () {
    final m = F0579MandelboxS15();
    expect(m.id, 'f0579_mandelbox_s_1_5');
    expect(m.shader, 'shaders/f0579_mandelbox_s_1_5_gpu.frag');
  });

  test('F0579MandelboxS15 presets are well-formed', () {
    final m = F0579MandelboxS15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0579MandelboxS15 metadata is consistent', () {
    final m = F0579MandelboxS15();
    expect(m.metadata.id, m.id);
  });
}
