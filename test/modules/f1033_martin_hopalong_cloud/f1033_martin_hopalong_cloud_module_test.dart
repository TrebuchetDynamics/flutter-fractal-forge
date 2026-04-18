// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1033_martin_hopalong_cloud/f1033_martin_hopalong_cloud_module.dart';

void main() {
  test('F1033MartinHopalongCloud instantiates', () {
    final m = F1033MartinHopalongCloud();
    expect(m.id, 'f1033_martin_hopalong_cloud');
    expect(m.shader, 'shaders/f1033_martin_hopalong_cloud_gpu.frag');
  });

  test('F1033MartinHopalongCloud presets are well-formed', () {
    final m = F1033MartinHopalongCloud();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1033MartinHopalongCloud metadata is consistent', () {
    final m = F1033MartinHopalongCloud();
    expect(m.metadata.id, m.id);
  });
}
