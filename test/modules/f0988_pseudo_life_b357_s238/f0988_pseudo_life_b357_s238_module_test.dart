// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0988_pseudo_life_b357_s238/f0988_pseudo_life_b357_s238_module.dart';

void main() {
  test('F0988PseudoLifeB357S238 instantiates', () {
    final m = F0988PseudoLifeB357S238();
    expect(m.id, 'f0988_pseudo_life_b357_s238');
    expect(m.shader, 'shaders/f0988_pseudo_life_b357_s238_gpu.frag');
  });

  test('F0988PseudoLifeB357S238 presets are well-formed', () {
    final m = F0988PseudoLifeB357S238();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0988PseudoLifeB357S238 metadata is consistent', () {
    final m = F0988PseudoLifeB357S238();
    expect(m.metadata.id, m.id);
  });
}
