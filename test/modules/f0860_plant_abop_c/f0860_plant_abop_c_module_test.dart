// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0860_plant_abop_c/f0860_plant_abop_c_module.dart';

void main() {
  test('F0860PlantAbopC instantiates', () {
    final m = F0860PlantAbopC();
    expect(m.id, 'f0860_plant_abop_c');
    expect(m.shader, 'shaders/f0860_plant_abop_c_gpu.frag');
  });

  test('F0860PlantAbopC presets are well-formed', () {
    final m = F0860PlantAbopC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0860PlantAbopC metadata is consistent', () {
    final m = F0860PlantAbopC();
    expect(m.metadata.id, m.id);
  });
}
