// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0470_double_spiral_valley/f0470_double_spiral_valley_module.dart';

void main() {
  test('F0470DoubleSpiralValley instantiates', () {
    final m = F0470DoubleSpiralValley();
    expect(m.id, 'f0470_double_spiral_valley');
    expect(m.shader, 'shaders/f0470_double_spiral_valley_gpu.frag');
  });

  test('F0470DoubleSpiralValley presets are well-formed', () {
    final m = F0470DoubleSpiralValley();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0470DoubleSpiralValley metadata is consistent', () {
    final m = F0470DoubleSpiralValley();
    expect(m.metadata.id, m.id);
  });
}
