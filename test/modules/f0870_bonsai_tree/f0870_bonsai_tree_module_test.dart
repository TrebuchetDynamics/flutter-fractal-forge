// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0870_bonsai_tree/f0870_bonsai_tree_module.dart';

void main() {
  test('F0870BonsaiTree instantiates', () {
    final m = F0870BonsaiTree();
    expect(m.id, 'f0870_bonsai_tree');
    expect(m.shader, 'shaders/f0870_bonsai_tree_gpu.frag');
  });

  test('F0870BonsaiTree presets are well-formed', () {
    final m = F0870BonsaiTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0870BonsaiTree metadata is consistent', () {
    final m = F0870BonsaiTree();
    expect(m.metadata.id, m.id);
  });
}
