// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1028_martin_hopalong_classic/f1028_martin_hopalong_classic_module.dart';

void main() {
  test('F1028MartinHopalongClassic instantiates', () {
    final m = F1028MartinHopalongClassic();
    expect(m.id, 'f1028_martin_hopalong_classic');
    expect(m.shader, 'shaders/f1028_martin_hopalong_classic_gpu.frag');
  });

  test('F1028MartinHopalongClassic presets are well-formed', () {
    final m = F1028MartinHopalongClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1028MartinHopalongClassic metadata is consistent', () {
    final m = F1028MartinHopalongClassic();
    expect(m.metadata.id, m.id);
  });
}
