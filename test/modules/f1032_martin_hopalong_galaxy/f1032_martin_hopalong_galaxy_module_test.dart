// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1032_martin_hopalong_galaxy/f1032_martin_hopalong_galaxy_module.dart';

void main() {
  test('F1032MartinHopalongGalaxy instantiates', () {
    final m = F1032MartinHopalongGalaxy();
    expect(m.id, 'f1032_martin_hopalong_galaxy');
    expect(m.shader, 'shaders/f1032_martin_hopalong_galaxy_gpu.frag');
  });

  test('F1032MartinHopalongGalaxy presets are well-formed', () {
    final m = F1032MartinHopalongGalaxy();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1032MartinHopalongGalaxy metadata is consistent', () {
    final m = F1032MartinHopalongGalaxy();
    expect(m.metadata.id, m.id);
  });
}
