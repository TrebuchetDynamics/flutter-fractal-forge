// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0841_lebesgue_curve/f0841_lebesgue_curve_module.dart';

void main() {
  test('F0841LebesgueCurve instantiates', () {
    final m = F0841LebesgueCurve();
    expect(m.id, 'f0841_lebesgue_curve');
    expect(m.shader, 'shaders/f0841_lebesgue_curve_gpu.frag');
  });

  test('F0841LebesgueCurve presets are well-formed', () {
    final m = F0841LebesgueCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0841LebesgueCurve metadata is consistent', () {
    final m = F0841LebesgueCurve();
    expect(m.metadata.id, m.id);
  });
}
