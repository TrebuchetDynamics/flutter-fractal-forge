// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0850_christmas_tree_symmetric/f0850_christmas_tree_symmetric_module.dart';

void main() {
  test('F0850ChristmasTreeSymmetric instantiates', () {
    final m = F0850ChristmasTreeSymmetric();
    expect(m.id, 'f0850_christmas_tree_symmetric');
    expect(m.shader, 'shaders/f0850_christmas_tree_symmetric_gpu.frag');
  });

  test('F0850ChristmasTreeSymmetric presets are well-formed', () {
    final m = F0850ChristmasTreeSymmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0850ChristmasTreeSymmetric metadata is consistent', () {
    final m = F0850ChristmasTreeSymmetric();
    expect(m.metadata.id, m.id);
  });
}
