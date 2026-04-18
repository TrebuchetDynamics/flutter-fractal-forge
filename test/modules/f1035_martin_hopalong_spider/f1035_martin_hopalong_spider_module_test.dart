// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1035_martin_hopalong_spider/f1035_martin_hopalong_spider_module.dart';

void main() {
  test('F1035MartinHopalongSpider instantiates', () {
    final m = F1035MartinHopalongSpider();
    expect(m.id, 'f1035_martin_hopalong_spider');
    expect(m.shader, 'shaders/f1035_martin_hopalong_spider_gpu.frag');
  });

  test('F1035MartinHopalongSpider presets are well-formed', () {
    final m = F1035MartinHopalongSpider();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1035MartinHopalongSpider metadata is consistent', () {
    final m = F1035MartinHopalongSpider();
    expect(m.metadata.id, m.id);
  });
}
