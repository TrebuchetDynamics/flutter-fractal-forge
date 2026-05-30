// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0467_arithmetic_spiral/f0467_arithmetic_spiral_module.dart';

void main() {
  test('F0467ArithmeticSpiral instantiates', () {
    final m = F0467ArithmeticSpiral();
    expect(m.id, 'f0467_arithmetic_spiral');
    expect(m.shader, 'shaders/f0467_arithmetic_spiral_gpu.frag');
  });

  test('F0467ArithmeticSpiral presets are well-formed', () {
    final m = F0467ArithmeticSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0467ArithmeticSpiral metadata is consistent', () {
    final m = F0467ArithmeticSpiral();
    expect(m.metadata.id, m.id);
  });
}
