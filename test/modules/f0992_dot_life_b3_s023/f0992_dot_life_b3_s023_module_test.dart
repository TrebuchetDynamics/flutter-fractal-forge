// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0992_dot_life_b3_s023/f0992_dot_life_b3_s023_module.dart';

void main() {
  test('F0992DotLifeB3S023 instantiates', () {
    final m = F0992DotLifeB3S023();
    expect(m.id, 'f0992_dot_life_b3_s023');
    expect(m.shader, 'shaders/f0992_dot_life_b3_s023_gpu.frag');
  });

  test('F0992DotLifeB3S023 presets are well-formed', () {
    final m = F0992DotLifeB3S023();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0992DotLifeB3S023 metadata is consistent', () {
    final m = F0992DotLifeB3S023();
    expect(m.metadata.id, m.id);
  });
}
