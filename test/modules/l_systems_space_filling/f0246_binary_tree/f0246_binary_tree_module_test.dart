// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0246_binary_tree/f0246_binary_tree_module.dart';

void main() {
  test('F0246BinaryTree instantiates', () {
    final m = F0246BinaryTree();
    expect(m.id, 'f0246_binary_tree');
    expect(m.shader, 'shaders/f0246_binary_tree_gpu.frag');
  });

  test('F0246BinaryTree presets are well-formed', () {
    final m = F0246BinaryTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0246BinaryTree metadata is consistent', () {
    final m = F0246BinaryTree();
    expect(m.metadata.id, m.id);
  });
}
