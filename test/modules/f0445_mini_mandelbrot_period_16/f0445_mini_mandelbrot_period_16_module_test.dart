// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0445_mini_mandelbrot_period_16/f0445_mini_mandelbrot_period_16_module.dart';

void main() {
  test('F0445MiniMandelbrotPeriod16 instantiates', () {
    final m = F0445MiniMandelbrotPeriod16();
    expect(m.id, 'f0445_mini_mandelbrot_period_16');
    expect(m.shader, 'shaders/f0445_mini_mandelbrot_period_16_gpu.frag');
  });

  test('F0445MiniMandelbrotPeriod16 presets are well-formed', () {
    final m = F0445MiniMandelbrotPeriod16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0445MiniMandelbrotPeriod16 metadata is consistent', () {
    final m = F0445MiniMandelbrotPeriod16();
    expect(m.metadata.id, m.id);
  });
}
