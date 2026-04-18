// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1038_martin_hopalong_vortex/f1038_martin_hopalong_vortex_module.dart';

void main() {
  test('F1038MartinHopalongVortex instantiates', () {
    final m = F1038MartinHopalongVortex();
    expect(m.id, 'f1038_martin_hopalong_vortex');
    expect(m.shader, 'shaders/f1038_martin_hopalong_vortex_gpu.frag');
  });

  test('F1038MartinHopalongVortex presets are well-formed', () {
    final m = F1038MartinHopalongVortex();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1038MartinHopalongVortex metadata is consistent', () {
    final m = F1038MartinHopalongVortex();
    expect(m.metadata.id, m.id);
  });
}
