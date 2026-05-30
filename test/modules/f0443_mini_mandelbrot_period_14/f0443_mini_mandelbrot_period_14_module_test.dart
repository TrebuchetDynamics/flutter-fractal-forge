// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0443_mini_mandelbrot_period_14/f0443_mini_mandelbrot_period_14_module.dart';

void main() {
  test('F0443MiniMandelbrotPeriod14 instantiates', () {
    final m = F0443MiniMandelbrotPeriod14();
    expect(m.id, 'f0443_mini_mandelbrot_period_14');
    expect(m.shader, 'shaders/f0443_mini_mandelbrot_period_14_gpu.frag');
  });

  test('F0443MiniMandelbrotPeriod14 presets are well-formed', () {
    final m = F0443MiniMandelbrotPeriod14();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0443MiniMandelbrotPeriod14 metadata is consistent', () {
    final m = F0443MiniMandelbrotPeriod14();
    expect(m.metadata.id, m.id);
  });
}
