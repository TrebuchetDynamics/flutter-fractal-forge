// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0435_mini_mandelbrot_period_6/f0435_mini_mandelbrot_period_6_module.dart';

void main() {
  test('F0435MiniMandelbrotPeriod6 instantiates', () {
    final m = F0435MiniMandelbrotPeriod6();
    expect(m.id, 'f0435_mini_mandelbrot_period_6');
    expect(m.shader, 'shaders/f0435_mini_mandelbrot_period_6_gpu.frag');
  });

  test('F0435MiniMandelbrotPeriod6 presets are well-formed', () {
    final m = F0435MiniMandelbrotPeriod6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0435MiniMandelbrotPeriod6 metadata is consistent', () {
    final m = F0435MiniMandelbrotPeriod6();
    expect(m.metadata.id, m.id);
  });
}
