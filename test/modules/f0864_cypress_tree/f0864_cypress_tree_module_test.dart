// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0864_cypress_tree/f0864_cypress_tree_module.dart';

void main() {
  test('F0864CypressTree instantiates', () {
    final m = F0864CypressTree();
    expect(m.id, 'f0864_cypress_tree');
    expect(m.shader, 'shaders/f0864_cypress_tree_gpu.frag');
  });

  test('F0864CypressTree presets are well-formed', () {
    final m = F0864CypressTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0864CypressTree metadata is consistent', () {
    final m = F0864CypressTree();
    expect(m.metadata.id, m.id);
  });
}
