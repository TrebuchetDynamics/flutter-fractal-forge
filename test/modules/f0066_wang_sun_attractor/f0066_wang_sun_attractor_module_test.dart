// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0066_wang_sun_attractor/f0066_wang_sun_attractor_module.dart';

void main() {
  test('F0066WangSunAttractor instantiates', () {
    final m = F0066WangSunAttractor();
    expect(m.id, 'f0066_wang_sun_attractor');
    expect(m.shader, 'shaders/f0066_wang_sun_attractor_gpu.frag');
  });

  test('F0066WangSunAttractor presets are well-formed', () {
    final m = F0066WangSunAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0066WangSunAttractor metadata is consistent', () {
    final m = F0066WangSunAttractor();
    expect(m.metadata.id, m.id);
  });
}
