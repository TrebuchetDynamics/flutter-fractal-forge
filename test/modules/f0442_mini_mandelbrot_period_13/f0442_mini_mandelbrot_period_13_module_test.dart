// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0442_mini_mandelbrot_period_13/f0442_mini_mandelbrot_period_13_module.dart';

void main() {
  test('F0442MiniMandelbrotPeriod13 instantiates', () {
    final m = F0442MiniMandelbrotPeriod13();
    expect(m.id, 'f0442_mini_mandelbrot_period_13');
    expect(m.shader, 'shaders/f0442_mini_mandelbrot_period_13_gpu.frag');
  });

  test('F0442MiniMandelbrotPeriod13 presets are well-formed', () {
    final m = F0442MiniMandelbrotPeriod13();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0442MiniMandelbrotPeriod13 metadata is consistent', () {
    final m = F0442MiniMandelbrotPeriod13();
    expect(m.metadata.id, m.id);
  });
}
