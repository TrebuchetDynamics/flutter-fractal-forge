// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0124_cubic_mandelbrot_c_additive/f0124_cubic_mandelbrot_c_additive_module.dart';

void main() {
  test('F0124CubicMandelbrotCAdditive instantiates', () {
    final m = F0124CubicMandelbrotCAdditive();
    expect(m.id, 'f0124_cubic_mandelbrot_c_additive');
    expect(m.shader, 'shaders/f0124_cubic_mandelbrot_c_additive_gpu.frag');
  });

  test('F0124CubicMandelbrotCAdditive presets are well-formed', () {
    final m = F0124CubicMandelbrotCAdditive();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0124CubicMandelbrotCAdditive metadata is consistent', () {
    final m = F0124CubicMandelbrotCAdditive();
    expect(m.metadata.id, m.id);
  });
}
