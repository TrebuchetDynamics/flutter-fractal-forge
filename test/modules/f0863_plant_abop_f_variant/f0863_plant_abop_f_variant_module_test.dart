// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0863_plant_abop_f_variant/f0863_plant_abop_f_variant_module.dart';

void main() {
  test('F0863PlantAbopFVariant instantiates', () {
    final m = F0863PlantAbopFVariant();
    expect(m.id, 'f0863_plant_abop_f_variant');
    expect(m.shader, 'shaders/f0863_plant_abop_f_variant_gpu.frag');
  });

  test('F0863PlantAbopFVariant presets are well-formed', () {
    final m = F0863PlantAbopFVariant();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0863PlantAbopFVariant metadata is consistent', () {
    final m = F0863PlantAbopFVariant();
    expect(m.metadata.id, m.id);
  });
}
