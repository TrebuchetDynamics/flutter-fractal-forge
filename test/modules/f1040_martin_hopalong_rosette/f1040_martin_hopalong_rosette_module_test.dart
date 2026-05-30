// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1040_martin_hopalong_rosette/f1040_martin_hopalong_rosette_module.dart';

void main() {
  test('F1040MartinHopalongRosette instantiates', () {
    final m = F1040MartinHopalongRosette();
    expect(m.id, 'f1040_martin_hopalong_rosette');
    expect(m.shader, 'shaders/f1040_martin_hopalong_rosette_gpu.frag');
  });

  test('F1040MartinHopalongRosette presets are well-formed', () {
    final m = F1040MartinHopalongRosette();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1040MartinHopalongRosette metadata is consistent', () {
    final m = F1040MartinHopalongRosette();
    expect(m.metadata.id, m.id);
  });
}
