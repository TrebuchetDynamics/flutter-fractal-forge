// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0448_mini_mandelbrot_period_19/f0448_mini_mandelbrot_period_19_module.dart';

void main() {
  test('F0448MiniMandelbrotPeriod19 instantiates', () {
    final m = F0448MiniMandelbrotPeriod19();
    expect(m.id, 'f0448_mini_mandelbrot_period_19');
    expect(m.shader, 'shaders/f0448_mini_mandelbrot_period_19_gpu.frag');
  });

  test('F0448MiniMandelbrotPeriod19 presets are well-formed', () {
    final m = F0448MiniMandelbrotPeriod19();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0448MiniMandelbrotPeriod19 metadata is consistent', () {
    final m = F0448MiniMandelbrotPeriod19();
    expect(m.metadata.id, m.id);
  });
}
