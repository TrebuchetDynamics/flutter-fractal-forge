// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0859_plant_abop_b/f0859_plant_abop_b_module.dart';

void main() {
  test('F0859PlantAbopB instantiates', () {
    final m = F0859PlantAbopB();
    expect(m.id, 'f0859_plant_abop_b');
    expect(m.shader, 'shaders/f0859_plant_abop_b_gpu.frag');
  });

  test('F0859PlantAbopB presets are well-formed', () {
    final m = F0859PlantAbopB();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0859PlantAbopB metadata is consistent', () {
    final m = F0859PlantAbopB();
    expect(m.metadata.id, m.id);
  });
}
