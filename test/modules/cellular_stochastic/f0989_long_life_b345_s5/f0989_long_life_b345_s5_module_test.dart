// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0989_long_life_b345_s5/f0989_long_life_b345_s5_module.dart';

void main() {
  test('F0989LongLifeB345S5 instantiates', () {
    final m = F0989LongLifeB345S5();
    expect(m.id, 'f0989_long_life_b345_s5');
    expect(m.shader, 'shaders/f0989_long_life_b345_s5_gpu.frag');
  });

  test('F0989LongLifeB345S5 presets are well-formed', () {
    final m = F0989LongLifeB345S5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0989LongLifeB345S5 metadata is consistent', () {
    final m = F0989LongLifeB345S5();
    expect(m.metadata.id, m.id);
  });
}
