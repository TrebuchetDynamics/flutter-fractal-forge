// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0247_ternary_tree/f0247_ternary_tree_module.dart';

void main() {
  test('F0247TernaryTree instantiates', () {
    final m = F0247TernaryTree();
    expect(m.id, 'f0247_ternary_tree');
    expect(m.shader, 'shaders/f0247_ternary_tree_gpu.frag');
  });

  test('F0247TernaryTree presets are well-formed', () {
    final m = F0247TernaryTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0247TernaryTree metadata is consistent', () {
    final m = F0247TernaryTree();
    expect(m.metadata.id, m.id);
  });
}
