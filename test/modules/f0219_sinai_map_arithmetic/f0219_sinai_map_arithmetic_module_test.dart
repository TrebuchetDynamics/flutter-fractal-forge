// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0219_sinai_map_arithmetic/f0219_sinai_map_arithmetic_module.dart';

void main() {
  test('F0219SinaiMapArithmetic instantiates', () {
    final m = F0219SinaiMapArithmetic();
    expect(m.id, 'f0219_sinai_map_arithmetic');
    expect(m.shader, 'shaders/f0219_sinai_map_arithmetic_gpu.frag');
  });

  test('F0219SinaiMapArithmetic presets are well-formed', () {
    final m = F0219SinaiMapArithmetic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0219SinaiMapArithmetic metadata is consistent', () {
    final m = F0219SinaiMapArithmetic();
    expect(m.metadata.id, m.id);
  });
}
