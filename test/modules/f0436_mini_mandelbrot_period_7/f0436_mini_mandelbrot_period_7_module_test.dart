// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0436_mini_mandelbrot_period_7/f0436_mini_mandelbrot_period_7_module.dart';

void main() {
  test('F0436MiniMandelbrotPeriod7 instantiates', () {
    final m = F0436MiniMandelbrotPeriod7();
    expect(m.id, 'f0436_mini_mandelbrot_period_7');
    expect(m.shader, 'shaders/f0436_mini_mandelbrot_period_7_gpu.frag');
  });

  test('F0436MiniMandelbrotPeriod7 presets are well-formed', () {
    final m = F0436MiniMandelbrotPeriod7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0436MiniMandelbrotPeriod7 metadata is consistent', () {
    final m = F0436MiniMandelbrotPeriod7();
    expect(m.metadata.id, m.id);
  });
}
