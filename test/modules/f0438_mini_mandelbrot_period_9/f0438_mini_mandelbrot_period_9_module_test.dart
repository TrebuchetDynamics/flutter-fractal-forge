// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0438_mini_mandelbrot_period_9/f0438_mini_mandelbrot_period_9_module.dart';

void main() {
  test('F0438MiniMandelbrotPeriod9 instantiates', () {
    final m = F0438MiniMandelbrotPeriod9();
    expect(m.id, 'f0438_mini_mandelbrot_period_9');
    expect(m.shader, 'shaders/f0438_mini_mandelbrot_period_9_gpu.frag');
  });

  test('F0438MiniMandelbrotPeriod9 presets are well-formed', () {
    final m = F0438MiniMandelbrotPeriod9();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0438MiniMandelbrotPeriod9 metadata is consistent', () {
    final m = F0438MiniMandelbrotPeriod9();
    expect(m.metadata.id, m.id);
  });
}
