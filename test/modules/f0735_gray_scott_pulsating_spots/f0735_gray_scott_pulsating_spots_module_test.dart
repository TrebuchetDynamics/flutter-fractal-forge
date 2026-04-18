// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0735_gray_scott_pulsating_spots/f0735_gray_scott_pulsating_spots_module.dart';

void main() {
  test('F0735GrayScottPulsatingSpots instantiates', () {
    final m = F0735GrayScottPulsatingSpots();
    expect(m.id, 'f0735_gray_scott_pulsating_spots');
    expect(m.shader, 'shaders/f0735_gray_scott_pulsating_spots_gpu.frag');
  });

  test('F0735GrayScottPulsatingSpots presets are well-formed', () {
    final m = F0735GrayScottPulsatingSpots();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0735GrayScottPulsatingSpots metadata is consistent', () {
    final m = F0735GrayScottPulsatingSpots();
    expect(m.metadata.id, m.id);
  });
}
