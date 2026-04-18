// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0793_sacks_spiral/f0793_sacks_spiral_module.dart';

void main() {
  test('F0793SacksSpiral instantiates', () {
    final m = F0793SacksSpiral();
    expect(m.id, 'f0793_sacks_spiral');
    expect(m.shader, 'shaders/f0793_sacks_spiral_gpu.frag');
  });

  test('F0793SacksSpiral presets are well-formed', () {
    final m = F0793SacksSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0793SacksSpiral metadata is consistent', () {
    final m = F0793SacksSpiral();
    expect(m.metadata.id, m.id);
  });
}
