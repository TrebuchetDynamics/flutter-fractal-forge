// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0233_mcworter_pentigree/f0233_mcworter_pentigree_module.dart';

void main() {
  test('F0233McworterPentigree instantiates', () {
    final m = F0233McworterPentigree();
    expect(m.id, 'f0233_mcworter_pentigree');
    expect(m.shader, 'shaders/f0233_mcworter_pentigree_gpu.frag');
  });

  test('F0233McworterPentigree presets are well-formed', () {
    final m = F0233McworterPentigree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0233McworterPentigree metadata is consistent', () {
    final m = F0233McworterPentigree();
    expect(m.metadata.id, m.id);
  });
}
