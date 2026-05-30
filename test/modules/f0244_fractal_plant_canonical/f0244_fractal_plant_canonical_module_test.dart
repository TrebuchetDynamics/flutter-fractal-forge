// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0244_fractal_plant_canonical/f0244_fractal_plant_canonical_module.dart';

void main() {
  test('F0244FractalPlantCanonical instantiates', () {
    final m = F0244FractalPlantCanonical();
    expect(m.id, 'f0244_fractal_plant_canonical');
    expect(m.shader, 'shaders/f0244_fractal_plant_canonical_gpu.frag');
  });

  test('F0244FractalPlantCanonical presets are well-formed', () {
    final m = F0244FractalPlantCanonical();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0244FractalPlantCanonical metadata is consistent', () {
    final m = F0244FractalPlantCanonical();
    expect(m.metadata.id, m.id);
  });
}
