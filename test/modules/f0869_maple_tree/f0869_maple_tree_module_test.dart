// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0869_maple_tree/f0869_maple_tree_module.dart';

void main() {
  test('F0869MapleTree instantiates', () {
    final m = F0869MapleTree();
    expect(m.id, 'f0869_maple_tree');
    expect(m.shader, 'shaders/f0869_maple_tree_gpu.frag');
  });

  test('F0869MapleTree presets are well-formed', () {
    final m = F0869MapleTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0869MapleTree metadata is consistent', () {
    final m = F0869MapleTree();
    expect(m.metadata.id, m.id);
  });
}
