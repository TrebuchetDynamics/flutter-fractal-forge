// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0865_oak_tree/f0865_oak_tree_module.dart';

void main() {
  test('F0865OakTree instantiates', () {
    final m = F0865OakTree();
    expect(m.id, 'f0865_oak_tree');
    expect(m.shader, 'shaders/f0865_oak_tree_gpu.frag');
  });

  test('F0865OakTree presets are well-formed', () {
    final m = F0865OakTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0865OakTree metadata is consistent', () {
    final m = F0865OakTree();
    expect(m.metadata.id, m.id);
  });
}
