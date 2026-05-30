// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0224_koch_square_curve/f0224_koch_square_curve_module.dart';

void main() {
  test('F0224KochSquareCurve instantiates', () {
    final m = F0224KochSquareCurve();
    expect(m.id, 'f0224_koch_square_curve');
    expect(m.shader, 'shaders/f0224_koch_square_curve_gpu.frag');
  });

  test('F0224KochSquareCurve presets are well-formed', () {
    final m = F0224KochSquareCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0224KochSquareCurve metadata is consistent', () {
    final m = F0224KochSquareCurve();
    expect(m.metadata.id, m.id);
  });
}
