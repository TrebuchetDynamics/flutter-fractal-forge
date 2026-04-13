// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0279_binary_tree_ifs/f0279_binary_tree_ifs_module.dart';

void main() {
  test('F0279BinaryTreeIfs instantiates', () {
    final m = F0279BinaryTreeIfs();
    expect(m.id, 'f0279_binary_tree_ifs');
    expect(m.shader, 'shaders/f0279_binary_tree_ifs_gpu.frag');
  });

  test('F0279BinaryTreeIfs presets are well-formed', () {
    final m = F0279BinaryTreeIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0279BinaryTreeIfs metadata is consistent', () {
    final m = F0279BinaryTreeIfs();
    expect(m.metadata.id, m.id);
  });
}
