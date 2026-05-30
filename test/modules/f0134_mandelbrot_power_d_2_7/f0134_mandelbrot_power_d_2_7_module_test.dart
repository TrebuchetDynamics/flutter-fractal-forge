// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0134_mandelbrot_power_d_2_7/f0134_mandelbrot_power_d_2_7_module.dart';

void main() {
  test('F0134MandelbrotPowerD27 instantiates', () {
    final m = F0134MandelbrotPowerD27();
    expect(m.id, 'f0134_mandelbrot_power_d_2_7');
    expect(m.shader, 'shaders/f0134_mandelbrot_power_d_2_7_gpu.frag');
  });

  test('F0134MandelbrotPowerD27 presets are well-formed', () {
    final m = F0134MandelbrotPowerD27();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0134MandelbrotPowerD27 metadata is consistent', () {
    final m = F0134MandelbrotPowerD27();
    expect(m.metadata.id, m.id);
  });
}
