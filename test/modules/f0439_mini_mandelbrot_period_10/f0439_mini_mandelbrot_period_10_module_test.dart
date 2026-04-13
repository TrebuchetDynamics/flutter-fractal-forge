// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0439_mini_mandelbrot_period_10/f0439_mini_mandelbrot_period_10_module.dart';

void main() {
  test('F0439MiniMandelbrotPeriod10 instantiates', () {
    final m = F0439MiniMandelbrotPeriod10();
    expect(m.id, 'f0439_mini_mandelbrot_period_10');
    expect(m.shader, 'shaders/f0439_mini_mandelbrot_period_10_gpu.frag');
  });

  test('F0439MiniMandelbrotPeriod10 presets are well-formed', () {
    final m = F0439MiniMandelbrotPeriod10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0439MiniMandelbrotPeriod10 metadata is consistent', () {
    final m = F0439MiniMandelbrotPeriod10();
    expect(m.metadata.id, m.id);
  });
}
