// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0444_mini_mandelbrot_period_15/f0444_mini_mandelbrot_period_15_module.dart';

void main() {
  test('F0444MiniMandelbrotPeriod15 instantiates', () {
    final m = F0444MiniMandelbrotPeriod15();
    expect(m.id, 'f0444_mini_mandelbrot_period_15');
    expect(m.shader, 'shaders/f0444_mini_mandelbrot_period_15_gpu.frag');
  });

  test('F0444MiniMandelbrotPeriod15 presets are well-formed', () {
    final m = F0444MiniMandelbrotPeriod15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0444MiniMandelbrotPeriod15 metadata is consistent', () {
    final m = F0444MiniMandelbrotPeriod15();
    expect(m.metadata.id, m.id);
  });
}
