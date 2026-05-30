// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0862_plant_abop_e/f0862_plant_abop_e_module.dart';

void main() {
  test('F0862PlantAbopE instantiates', () {
    final m = F0862PlantAbopE();
    expect(m.id, 'f0862_plant_abop_e');
    expect(m.shader, 'shaders/f0862_plant_abop_e_gpu.frag');
  });

  test('F0862PlantAbopE presets are well-formed', () {
    final m = F0862PlantAbopE();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0862PlantAbopE metadata is consistent', () {
    final m = F0862PlantAbopE();
    expect(m.metadata.id, m.id);
  });
}
