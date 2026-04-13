// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0440_mini_mandelbrot_period_11/f0440_mini_mandelbrot_period_11_module.dart';

void main() {
  test('F0440MiniMandelbrotPeriod11 instantiates', () {
    final m = F0440MiniMandelbrotPeriod11();
    expect(m.id, 'f0440_mini_mandelbrot_period_11');
    expect(m.shader, 'shaders/f0440_mini_mandelbrot_period_11_gpu.frag');
  });

  test('F0440MiniMandelbrotPeriod11 presets are well-formed', () {
    final m = F0440MiniMandelbrotPeriod11();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0440MiniMandelbrotPeriod11 metadata is consistent', () {
    final m = F0440MiniMandelbrotPeriod11();
    expect(m.metadata.id, m.id);
  });
}
