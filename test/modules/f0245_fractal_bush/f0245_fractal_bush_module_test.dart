// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0245_fractal_bush/f0245_fractal_bush_module.dart';

void main() {
  test('F0245FractalBush instantiates', () {
    final m = F0245FractalBush();
    expect(m.id, 'f0245_fractal_bush');
    expect(m.shader, 'shaders/f0245_fractal_bush_gpu.frag');
  });

  test('F0245FractalBush presets are well-formed', () {
    final m = F0245FractalBush();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0245FractalBush metadata is consistent', () {
    final m = F0245FractalBush();
    expect(m.metadata.id, m.id);
  });
}
