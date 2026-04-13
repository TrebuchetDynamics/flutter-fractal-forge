// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0447_mini_mandelbrot_period_18/f0447_mini_mandelbrot_period_18_module.dart';

void main() {
  test('F0447MiniMandelbrotPeriod18 instantiates', () {
    final m = F0447MiniMandelbrotPeriod18();
    expect(m.id, 'f0447_mini_mandelbrot_period_18');
    expect(m.shader, 'shaders/f0447_mini_mandelbrot_period_18_gpu.frag');
  });

  test('F0447MiniMandelbrotPeriod18 presets are well-formed', () {
    final m = F0447MiniMandelbrotPeriod18();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0447MiniMandelbrotPeriod18 metadata is consistent', () {
    final m = F0447MiniMandelbrotPeriod18();
    expect(m.metadata.id, m.id);
  });
}
