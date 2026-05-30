// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1029_martin_hopalong_wide/f1029_martin_hopalong_wide_module.dart';

void main() {
  test('F1029MartinHopalongWide instantiates', () {
    final m = F1029MartinHopalongWide();
    expect(m.id, 'f1029_martin_hopalong_wide');
    expect(m.shader, 'shaders/f1029_martin_hopalong_wide_gpu.frag');
  });

  test('F1029MartinHopalongWide presets are well-formed', () {
    final m = F1029MartinHopalongWide();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1029MartinHopalongWide metadata is consistent', () {
    final m = F1029MartinHopalongWide();
    expect(m.metadata.id, m.id);
  });
}
