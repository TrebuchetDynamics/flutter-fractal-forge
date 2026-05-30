// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0449_mini_mandelbrot_period_20/f0449_mini_mandelbrot_period_20_module.dart';

void main() {
  test('F0449MiniMandelbrotPeriod20 instantiates', () {
    final m = F0449MiniMandelbrotPeriod20();
    expect(m.id, 'f0449_mini_mandelbrot_period_20');
    expect(m.shader, 'shaders/f0449_mini_mandelbrot_period_20_gpu.frag');
  });

  test('F0449MiniMandelbrotPeriod20 presets are well-formed', () {
    final m = F0449MiniMandelbrotPeriod20();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0449MiniMandelbrotPeriod20 metadata is consistent', () {
    final m = F0449MiniMandelbrotPeriod20();
    expect(m.metadata.id, m.id);
  });
}
