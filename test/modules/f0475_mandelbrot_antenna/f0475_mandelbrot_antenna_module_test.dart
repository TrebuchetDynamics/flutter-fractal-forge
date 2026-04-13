// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0475_mandelbrot_antenna/f0475_mandelbrot_antenna_module.dart';

void main() {
  test('F0475MandelbrotAntenna instantiates', () {
    final m = F0475MandelbrotAntenna();
    expect(m.id, 'f0475_mandelbrot_antenna');
    expect(m.shader, 'shaders/f0475_mandelbrot_antenna_gpu.frag');
  });

  test('F0475MandelbrotAntenna presets are well-formed', () {
    final m = F0475MandelbrotAntenna();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0475MandelbrotAntenna metadata is consistent', () {
    final m = F0475MandelbrotAntenna();
    expect(m.metadata.id, m.id);
  });
}
