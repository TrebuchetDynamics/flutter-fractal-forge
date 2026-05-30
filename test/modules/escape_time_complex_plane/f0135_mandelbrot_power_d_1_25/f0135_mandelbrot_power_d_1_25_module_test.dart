// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0135_mandelbrot_power_d_1_25/f0135_mandelbrot_power_d_1_25_module.dart';

void main() {
  test('F0135MandelbrotPowerD125 instantiates', () {
    final m = F0135MandelbrotPowerD125();
    expect(m.id, 'f0135_mandelbrot_power_d_1_25');
    expect(m.shader, 'shaders/f0135_mandelbrot_power_d_1_25_gpu.frag');
  });

  test('F0135MandelbrotPowerD125 presets are well-formed', () {
    final m = F0135MandelbrotPowerD125();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0135MandelbrotPowerD125 metadata is consistent', () {
    final m = F0135MandelbrotPowerD125();
    expect(m.metadata.id, m.id);
  });
}
