// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0810_bernoulli_shift/f0810_bernoulli_shift_module.dart';

void main() {
  test('F0810BernoulliShift instantiates', () {
    final m = F0810BernoulliShift();
    expect(m.id, 'f0810_bernoulli_shift');
    expect(m.shader, 'shaders/f0810_bernoulli_shift_gpu.frag');
  });

  test('F0810BernoulliShift presets are well-formed', () {
    final m = F0810BernoulliShift();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0810BernoulliShift metadata is consistent', () {
    final m = F0810BernoulliShift();
    expect(m.metadata.id, m.id);
  });
}
