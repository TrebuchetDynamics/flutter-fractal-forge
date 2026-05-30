// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0237_ces_ro_fractal/f0237_ces_ro_fractal_module.dart';

void main() {
  test('F0237CesRoFractal instantiates', () {
    final m = F0237CesRoFractal();
    expect(m.id, 'f0237_ces_ro_fractal');
    expect(m.shader, 'shaders/f0237_ces_ro_fractal_gpu.frag');
  });

  test('F0237CesRoFractal presets are well-formed', () {
    final m = F0237CesRoFractal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0237CesRoFractal metadata is consistent', () {
    final m = F0237CesRoFractal();
    expect(m.metadata.id, m.id);
  });
}
