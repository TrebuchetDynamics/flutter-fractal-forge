// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0441_mini_mandelbrot_period_12/f0441_mini_mandelbrot_period_12_module.dart';

void main() {
  test('F0441MiniMandelbrotPeriod12 instantiates', () {
    final m = F0441MiniMandelbrotPeriod12();
    expect(m.id, 'f0441_mini_mandelbrot_period_12');
    expect(m.shader, 'shaders/f0441_mini_mandelbrot_period_12_gpu.frag');
  });

  test('F0441MiniMandelbrotPeriod12 presets are well-formed', () {
    final m = F0441MiniMandelbrotPeriod12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0441MiniMandelbrotPeriod12 metadata is consistent', () {
    final m = F0441MiniMandelbrotPeriod12();
    expect(m.metadata.id, m.id);
  });
}
