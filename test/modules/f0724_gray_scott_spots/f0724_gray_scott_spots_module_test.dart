// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0724_gray_scott_spots/f0724_gray_scott_spots_module.dart';

void main() {
  test('F0724GrayScottSpots instantiates', () {
    final m = F0724GrayScottSpots();
    expect(m.id, 'f0724_gray_scott_spots');
    expect(m.shader, 'shaders/f0724_gray_scott_spots_gpu.frag');
  });

  test('F0724GrayScottSpots presets are well-formed', () {
    final m = F0724GrayScottSpots();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0724GrayScottSpots metadata is consistent', () {
    final m = F0724GrayScottSpots();
    expect(m.metadata.id, m.id);
  });
}
