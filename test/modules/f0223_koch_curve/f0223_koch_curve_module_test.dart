// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0223_koch_curve/f0223_koch_curve_module.dart';

void main() {
  test('F0223KochCurve instantiates', () {
    final m = F0223KochCurve();
    expect(m.id, 'f0223_koch_curve');
    expect(m.shader, 'shaders/f0223_koch_curve_gpu.frag');
  });

  test('F0223KochCurve presets are well-formed', () {
    final m = F0223KochCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0223KochCurve metadata is consistent', () {
    final m = F0223KochCurve();
    expect(m.metadata.id, m.id);
  });
}
