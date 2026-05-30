// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0570_mandelbox_s_1_5/f0570_mandelbox_s_1_5_module.dart';

void main() {
  test('F0570MandelboxS15 instantiates', () {
    final m = F0570MandelboxS15();
    expect(m.id, 'f0570_mandelbox_s_1_5');
    expect(m.shader, 'shaders/f0570_mandelbox_s_1_5_gpu.frag');
  });

  test('F0570MandelboxS15 presets are well-formed', () {
    final m = F0570MandelboxS15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0570MandelboxS15 metadata is consistent', () {
    final m = F0570MandelboxS15();
    expect(m.metadata.id, m.id);
  });
}
