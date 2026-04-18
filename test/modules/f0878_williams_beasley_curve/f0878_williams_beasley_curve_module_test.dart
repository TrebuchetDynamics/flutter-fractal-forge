// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0878_williams_beasley_curve/f0878_williams_beasley_curve_module.dart';

void main() {
  test('F0878WilliamsBeasleyCurve instantiates', () {
    final m = F0878WilliamsBeasleyCurve();
    expect(m.id, 'f0878_williams_beasley_curve');
    expect(m.shader, 'shaders/f0878_williams_beasley_curve_gpu.frag');
  });

  test('F0878WilliamsBeasleyCurve presets are well-formed', () {
    final m = F0878WilliamsBeasleyCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0878WilliamsBeasleyCurve metadata is consistent', () {
    final m = F0878WilliamsBeasleyCurve();
    expect(m.metadata.id, m.id);
  });
}
