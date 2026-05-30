// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0241_sierpinski_median_curve/f0241_sierpinski_median_curve_module.dart';

void main() {
  test('F0241SierpinskiMedianCurve instantiates', () {
    final m = F0241SierpinskiMedianCurve();
    expect(m.id, 'f0241_sierpinski_median_curve');
    expect(m.shader, 'shaders/f0241_sierpinski_median_curve_gpu.frag');
  });

  test('F0241SierpinskiMedianCurve presets are well-formed', () {
    final m = F0241SierpinskiMedianCurve();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0241SierpinskiMedianCurve metadata is consistent', () {
    final m = F0241SierpinskiMedianCurve();
    expect(m.metadata.id, m.id);
  });
}
