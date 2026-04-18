// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0725_gray_scott_worms/f0725_gray_scott_worms_module.dart';

void main() {
  test('F0725GrayScottWorms instantiates', () {
    final m = F0725GrayScottWorms();
    expect(m.id, 'f0725_gray_scott_worms');
    expect(m.shader, 'shaders/f0725_gray_scott_worms_gpu.frag');
  });

  test('F0725GrayScottWorms presets are well-formed', () {
    final m = F0725GrayScottWorms();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0725GrayScottWorms metadata is consistent', () {
    final m = F0725GrayScottWorms();
    expect(m.metadata.id, m.id);
  });
}
