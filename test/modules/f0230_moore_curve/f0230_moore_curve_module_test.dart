// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0230_moore_curve/f0230_moore_curve_module.dart';

void main() {
  test('F0230MooreCurve instantiates', () {
    final m = F0230MooreCurve();
    expect(m.id, 'f0230_moore_curve');
    expect(m.shader, 'shaders/f0230_moore_curve_gpu.frag');
  });

  test('F0230MooreCurve presets are well-formed', () {
    final m = F0230MooreCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0230MooreCurve metadata is consistent', () {
    final m = F0230MooreCurve();
    expect(m.metadata.id, m.id);
  });
}
