// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0732_gray_scott_moving_spots/f0732_gray_scott_moving_spots_module.dart';

void main() {
  test('F0732GrayScottMovingSpots instantiates', () {
    final m = F0732GrayScottMovingSpots();
    expect(m.id, 'f0732_gray_scott_moving_spots');
    expect(m.shader, 'shaders/f0732_gray_scott_moving_spots_gpu.frag');
  });

  test('F0732GrayScottMovingSpots presets are well-formed', () {
    final m = F0732GrayScottMovingSpots();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0732GrayScottMovingSpots metadata is consistent', () {
    final m = F0732GrayScottMovingSpots();
    expect(m.metadata.id, m.id);
  });
}
