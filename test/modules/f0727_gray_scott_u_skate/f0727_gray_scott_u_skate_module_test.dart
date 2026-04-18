// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0727_gray_scott_u_skate/f0727_gray_scott_u_skate_module.dart';

void main() {
  test('F0727GrayScottUSkate instantiates', () {
    final m = F0727GrayScottUSkate();
    expect(m.id, 'f0727_gray_scott_u_skate');
    expect(m.shader, 'shaders/f0727_gray_scott_u_skate_gpu.frag');
  });

  test('F0727GrayScottUSkate presets are well-formed', () {
    final m = F0727GrayScottUSkate();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0727GrayScottUSkate metadata is consistent', () {
    final m = F0727GrayScottUSkate();
    expect(m.metadata.id, m.id);
  });
}
