// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0127_lambda_mandelbrot/f0127_lambda_mandelbrot_module.dart';

void main() {
  test('F0127LambdaMandelbrot instantiates', () {
    final m = F0127LambdaMandelbrot();
    expect(m.id, 'f0127_lambda_mandelbrot');
    expect(m.shader, 'shaders/f0127_lambda_mandelbrot_gpu.frag');
  });

  test('F0127LambdaMandelbrot presets are well-formed', () {
    final m = F0127LambdaMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0127LambdaMandelbrot metadata is consistent', () {
    final m = F0127LambdaMandelbrot();
    expect(m.metadata.id, m.id);
  });
}
