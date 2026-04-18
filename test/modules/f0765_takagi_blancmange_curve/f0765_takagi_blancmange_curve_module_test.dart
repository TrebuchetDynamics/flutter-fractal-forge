// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0765_takagi_blancmange_curve/f0765_takagi_blancmange_curve_module.dart';

void main() {
  test('F0765TakagiBlancmangeCurve instantiates', () {
    final m = F0765TakagiBlancmangeCurve();
    expect(m.id, 'f0765_takagi_blancmange_curve');
    expect(m.shader, 'shaders/f0765_takagi_blancmange_curve_gpu.frag');
  });

  test('F0765TakagiBlancmangeCurve presets are well-formed', () {
    final m = F0765TakagiBlancmangeCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0765TakagiBlancmangeCurve metadata is consistent', () {
    final m = F0765TakagiBlancmangeCurve();
    expect(m.metadata.id, m.id);
  });
}
