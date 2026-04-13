// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0258_dragon_tree_hybrid/f0258_dragon_tree_hybrid_module.dart';

void main() {
  test('F0258DragonTreeHybrid instantiates', () {
    final m = F0258DragonTreeHybrid();
    expect(m.id, 'f0258_dragon_tree_hybrid');
    expect(m.shader, 'shaders/f0258_dragon_tree_hybrid_gpu.frag');
  });

  test('F0258DragonTreeHybrid presets are well-formed', () {
    final m = F0258DragonTreeHybrid();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0258DragonTreeHybrid metadata is consistent', () {
    final m = F0258DragonTreeHybrid();
    expect(m.metadata.id, m.id);
  });
}
