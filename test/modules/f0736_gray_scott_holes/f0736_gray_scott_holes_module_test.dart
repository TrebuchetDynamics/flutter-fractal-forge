// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0736_gray_scott_holes/f0736_gray_scott_holes_module.dart';

void main() {
  test('F0736GrayScottHoles instantiates', () {
    final m = F0736GrayScottHoles();
    expect(m.id, 'f0736_gray_scott_holes');
    expect(m.shader, 'shaders/f0736_gray_scott_holes_gpu.frag');
  });

  test('F0736GrayScottHoles presets are well-formed', () {
    final m = F0736GrayScottHoles();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0736GrayScottHoles metadata is consistent', () {
    final m = F0736GrayScottHoles();
    expect(m.metadata.id, m.id);
  });
}
