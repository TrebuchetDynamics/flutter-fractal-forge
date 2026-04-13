// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0125_quartic_mandelbrot_c_additive/f0125_quartic_mandelbrot_c_additive_module.dart';

void main() {
  test('F0125QuarticMandelbrotCAdditive instantiates', () {
    final m = F0125QuarticMandelbrotCAdditive();
    expect(m.id, 'f0125_quartic_mandelbrot_c_additive');
    expect(m.shader, 'shaders/f0125_quartic_mandelbrot_c_additive_gpu.frag');
  });

  test('F0125QuarticMandelbrotCAdditive presets are well-formed', () {
    final m = F0125QuarticMandelbrotCAdditive();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0125QuarticMandelbrotCAdditive metadata is consistent', () {
    final m = F0125QuarticMandelbrotCAdditive();
    expect(m.metadata.id, m.id);
  });
}
