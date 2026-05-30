// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0842_sierpinski_curve_closed/f0842_sierpinski_curve_closed_module.dart';

void main() {
  test('F0842SierpinskiCurveClosed instantiates', () {
    final m = F0842SierpinskiCurveClosed();
    expect(m.id, 'f0842_sierpinski_curve_closed');
    expect(m.shader, 'shaders/f0842_sierpinski_curve_closed_gpu.frag');
  });

  test('F0842SierpinskiCurveClosed presets are well-formed', () {
    final m = F0842SierpinskiCurveClosed();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0842SierpinskiCurveClosed metadata is consistent', () {
    final m = F0842SierpinskiCurveClosed();
    expect(m.metadata.id, m.id);
  });
}
