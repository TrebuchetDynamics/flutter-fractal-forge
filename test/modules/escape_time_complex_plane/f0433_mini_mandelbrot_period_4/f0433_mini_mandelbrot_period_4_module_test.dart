// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0433_mini_mandelbrot_period_4/f0433_mini_mandelbrot_period_4_module.dart';

void main() {
  test('F0433MiniMandelbrotPeriod4 instantiates', () {
    final m = F0433MiniMandelbrotPeriod4();
    expect(m.id, 'f0433_mini_mandelbrot_period_4');
    expect(m.shader, 'shaders/f0433_mini_mandelbrot_period_4_gpu.frag');
  });

  test('F0433MiniMandelbrotPeriod4 presets are well-formed', () {
    final m = F0433MiniMandelbrotPeriod4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0433MiniMandelbrotPeriod4 metadata is consistent', () {
    final m = F0433MiniMandelbrotPeriod4();
    expect(m.metadata.id, m.id);
  });
}
