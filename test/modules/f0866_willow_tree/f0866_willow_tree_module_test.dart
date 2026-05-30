// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0866_willow_tree/f0866_willow_tree_module.dart';

void main() {
  test('F0866WillowTree instantiates', () {
    final m = F0866WillowTree();
    expect(m.id, 'f0866_willow_tree');
    expect(m.shader, 'shaders/f0866_willow_tree_gpu.frag');
  });

  test('F0866WillowTree presets are well-formed', () {
    final m = F0866WillowTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0866WillowTree metadata is consistent', () {
    final m = F0866WillowTree();
    expect(m.metadata.id, m.id);
  });
}
