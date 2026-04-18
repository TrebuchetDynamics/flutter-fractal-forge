// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0835_moore_curve_closed_hilbert/f0835_moore_curve_closed_hilbert_module.dart';

void main() {
  test('F0835MooreCurveClosedHilbert instantiates', () {
    final m = F0835MooreCurveClosedHilbert();
    expect(m.id, 'f0835_moore_curve_closed_hilbert');
    expect(m.shader, 'shaders/f0835_moore_curve_closed_hilbert_gpu.frag');
  });

  test('F0835MooreCurveClosedHilbert presets are well-formed', () {
    final m = F0835MooreCurveClosedHilbert();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0835MooreCurveClosedHilbert metadata is consistent', () {
    final m = F0835MooreCurveClosedHilbert();
    expect(m.metadata.id, m.id);
  });
}
