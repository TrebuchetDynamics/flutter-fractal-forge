// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0867_birch_tree/f0867_birch_tree_module.dart';

void main() {
  test('F0867BirchTree instantiates', () {
    final m = F0867BirchTree();
    expect(m.id, 'f0867_birch_tree');
    expect(m.shader, 'shaders/f0867_birch_tree_gpu.frag');
  });

  test('F0867BirchTree presets are well-formed', () {
    final m = F0867BirchTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0867BirchTree metadata is consistent', () {
    final m = F0867BirchTree();
    expect(m.metadata.id, m.id);
  });
}
