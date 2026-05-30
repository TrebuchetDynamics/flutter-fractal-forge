// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0432_mini_mandelbrot_period_3/f0432_mini_mandelbrot_period_3_module.dart';

void main() {
  test('F0432MiniMandelbrotPeriod3 instantiates', () {
    final m = F0432MiniMandelbrotPeriod3();
    expect(m.id, 'f0432_mini_mandelbrot_period_3');
    expect(m.shader, 'shaders/f0432_mini_mandelbrot_period_3_gpu.frag');
  });

  test('F0432MiniMandelbrotPeriod3 presets are well-formed', () {
    final m = F0432MiniMandelbrotPeriod3();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0432MiniMandelbrotPeriod3 metadata is consistent', () {
    final m = F0432MiniMandelbrotPeriod3();
    expect(m.metadata.id, m.id);
  });
}
