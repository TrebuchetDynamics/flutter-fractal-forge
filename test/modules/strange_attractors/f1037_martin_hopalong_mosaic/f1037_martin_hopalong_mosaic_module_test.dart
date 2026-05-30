// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1037_martin_hopalong_mosaic/f1037_martin_hopalong_mosaic_module.dart';

void main() {
  test('F1037MartinHopalongMosaic instantiates', () {
    final m = F1037MartinHopalongMosaic();
    expect(m.id, 'f1037_martin_hopalong_mosaic');
    expect(m.shader, 'shaders/f1037_martin_hopalong_mosaic_gpu.frag');
  });

  test('F1037MartinHopalongMosaic presets are well-formed', () {
    final m = F1037MartinHopalongMosaic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1037MartinHopalongMosaic metadata is consistent', () {
    final m = F1037MartinHopalongMosaic();
    expect(m.metadata.id, m.id);
  });
}
