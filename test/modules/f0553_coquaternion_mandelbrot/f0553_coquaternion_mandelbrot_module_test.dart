// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0553_coquaternion_mandelbrot/f0553_coquaternion_mandelbrot_module.dart';

void main() {
  test('F0553CoquaternionMandelbrot instantiates', () {
    final m = F0553CoquaternionMandelbrot();
    expect(m.id, 'f0553_coquaternion_mandelbrot');
    expect(m.shader, 'shaders/f0553_coquaternion_mandelbrot_gpu.frag');
  });

  test('F0553CoquaternionMandelbrot presets are well-formed', () {
    final m = F0553CoquaternionMandelbrot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0553CoquaternionMandelbrot metadata is consistent', () {
    final m = F0553CoquaternionMandelbrot();
    expect(m.metadata.id, m.id);
  });
}
