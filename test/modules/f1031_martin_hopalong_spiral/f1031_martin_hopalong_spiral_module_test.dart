// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1031_martin_hopalong_spiral/f1031_martin_hopalong_spiral_module.dart';

void main() {
  test('F1031MartinHopalongSpiral instantiates', () {
    final m = F1031MartinHopalongSpiral();
    expect(m.id, 'f1031_martin_hopalong_spiral');
    expect(m.shader, 'shaders/f1031_martin_hopalong_spiral_gpu.frag');
  });

  test('F1031MartinHopalongSpiral presets are well-formed', () {
    final m = F1031MartinHopalongSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1031MartinHopalongSpiral metadata is consistent', () {
    final m = F1031MartinHopalongSpiral();
    expect(m.metadata.id, m.id);
  });
}
