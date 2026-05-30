// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1039_martin_hopalong_storm/f1039_martin_hopalong_storm_module.dart';

void main() {
  test('F1039MartinHopalongStorm instantiates', () {
    final m = F1039MartinHopalongStorm();
    expect(m.id, 'f1039_martin_hopalong_storm');
    expect(m.shader, 'shaders/f1039_martin_hopalong_storm_gpu.frag');
  });

  test('F1039MartinHopalongStorm presets are well-formed', () {
    final m = F1039MartinHopalongStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1039MartinHopalongStorm metadata is consistent', () {
    final m = F1039MartinHopalongStorm();
    expect(m.metadata.id, m.id);
  });
}
