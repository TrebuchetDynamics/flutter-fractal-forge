// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0868_pine_tree/f0868_pine_tree_module.dart';

void main() {
  test('F0868PineTree instantiates', () {
    final m = F0868PineTree();
    expect(m.id, 'f0868_pine_tree');
    expect(m.shader, 'shaders/f0868_pine_tree_gpu.frag');
  });

  test('F0868PineTree presets are well-formed', () {
    final m = F0868PineTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0868PineTree metadata is consistent', () {
    final m = F0868PineTree();
    expect(m.metadata.id, m.id);
  });
}
