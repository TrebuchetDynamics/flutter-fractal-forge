// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1034_martin_hopalong_diamond/f1034_martin_hopalong_diamond_module.dart';

void main() {
  test('F1034MartinHopalongDiamond instantiates', () {
    final m = F1034MartinHopalongDiamond();
    expect(m.id, 'f1034_martin_hopalong_diamond');
    expect(m.shader, 'shaders/f1034_martin_hopalong_diamond_gpu.frag');
  });

  test('F1034MartinHopalongDiamond presets are well-formed', () {
    final m = F1034MartinHopalongDiamond();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1034MartinHopalongDiamond metadata is consistent', () {
    final m = F1034MartinHopalongDiamond();
    expect(m.metadata.id, m.id);
  });
}
