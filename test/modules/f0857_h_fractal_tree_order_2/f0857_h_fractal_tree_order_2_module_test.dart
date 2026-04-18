// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0857_h_fractal_tree_order_2/f0857_h_fractal_tree_order_2_module.dart';

void main() {
  test('F0857HFractalTreeOrder2 instantiates', () {
    final m = F0857HFractalTreeOrder2();
    expect(m.id, 'f0857_h_fractal_tree_order_2');
    expect(m.shader, 'shaders/f0857_h_fractal_tree_order_2_gpu.frag');
  });

  test('F0857HFractalTreeOrder2 presets are well-formed', () {
    final m = F0857HFractalTreeOrder2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0857HFractalTreeOrder2 metadata is consistent', () {
    final m = F0857HFractalTreeOrder2();
    expect(m.metadata.id, m.id);
  });
}
