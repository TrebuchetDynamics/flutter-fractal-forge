// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0437_mini_mandelbrot_period_8/f0437_mini_mandelbrot_period_8_module.dart';

void main() {
  test('F0437MiniMandelbrotPeriod8 instantiates', () {
    final m = F0437MiniMandelbrotPeriod8();
    expect(m.id, 'f0437_mini_mandelbrot_period_8');
    expect(m.shader, 'shaders/f0437_mini_mandelbrot_period_8_gpu.frag');
  });

  test('F0437MiniMandelbrotPeriod8 presets are well-formed', () {
    final m = F0437MiniMandelbrotPeriod8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0437MiniMandelbrotPeriod8 metadata is consistent', () {
    final m = F0437MiniMandelbrotPeriod8();
    expect(m.metadata.id, m.id);
  });
}
