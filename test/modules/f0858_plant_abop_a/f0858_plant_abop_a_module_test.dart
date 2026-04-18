// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0858_plant_abop_a/f0858_plant_abop_a_module.dart';

void main() {
  test('F0858PlantAbopA instantiates', () {
    final m = F0858PlantAbopA();
    expect(m.id, 'f0858_plant_abop_a');
    expect(m.shader, 'shaders/f0858_plant_abop_a_gpu.frag');
  });

  test('F0858PlantAbopA presets are well-formed', () {
    final m = F0858PlantAbopA();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0858PlantAbopA metadata is consistent', () {
    final m = F0858PlantAbopA();
    expect(m.metadata.id, m.id);
  });
}
