// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0726_gray_scott_mazes/f0726_gray_scott_mazes_module.dart';

void main() {
  test('F0726GrayScottMazes instantiates', () {
    final m = F0726GrayScottMazes();
    expect(m.id, 'f0726_gray_scott_mazes');
    expect(m.shader, 'shaders/f0726_gray_scott_mazes_gpu.frag');
  });

  test('F0726GrayScottMazes presets are well-formed', () {
    final m = F0726GrayScottMazes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0726GrayScottMazes metadata is consistent', () {
    final m = F0726GrayScottMazes();
    expect(m.metadata.id, m.id);
  });
}
