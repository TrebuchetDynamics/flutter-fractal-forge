// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0431_mini_mandelbrot_period_2/f0431_mini_mandelbrot_period_2_module.dart';

void main() {
  test('F0431MiniMandelbrotPeriod2 instantiates', () {
    final m = F0431MiniMandelbrotPeriod2();
    expect(m.id, 'f0431_mini_mandelbrot_period_2');
    expect(m.shader, 'shaders/f0431_mini_mandelbrot_period_2_gpu.frag');
  });

  test('F0431MiniMandelbrotPeriod2 presets are well-formed', () {
    final m = F0431MiniMandelbrotPeriod2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0431MiniMandelbrotPeriod2 metadata is consistent', () {
    final m = F0431MiniMandelbrotPeriod2();
    expect(m.metadata.id, m.id);
  });
}
