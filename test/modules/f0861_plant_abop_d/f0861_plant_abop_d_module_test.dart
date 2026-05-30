// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0861_plant_abop_d/f0861_plant_abop_d_module.dart';

void main() {
  test('F0861PlantAbopD instantiates', () {
    final m = F0861PlantAbopD();
    expect(m.id, 'f0861_plant_abop_d');
    expect(m.shader, 'shaders/f0861_plant_abop_d_gpu.frag');
  });

  test('F0861PlantAbopD presets are well-formed', () {
    final m = F0861PlantAbopD();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0861PlantAbopD metadata is consistent', () {
    final m = F0861PlantAbopD();
    expect(m.metadata.id, m.id);
  });
}
