// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0840_mckenna_curve/f0840_mckenna_curve_module.dart';

void main() {
  test('F0840MckennaCurve instantiates', () {
    final m = F0840MckennaCurve();
    expect(m.id, 'f0840_mckenna_curve');
    expect(m.shader, 'shaders/f0840_mckenna_curve_gpu.frag');
  });

  test('F0840MckennaCurve presets are well-formed', () {
    final m = F0840MckennaCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0840MckennaCurve metadata is consistent', () {
    final m = F0840MckennaCurve();
    expect(m.metadata.id, m.id);
  });
}
