// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0856_h_fractal_tree_order_1/f0856_h_fractal_tree_order_1_module.dart';

void main() {
  test('F0856HFractalTreeOrder1 instantiates', () {
    final m = F0856HFractalTreeOrder1();
    expect(m.id, 'f0856_h_fractal_tree_order_1');
    expect(m.shader, 'shaders/f0856_h_fractal_tree_order_1_gpu.frag');
  });

  test('F0856HFractalTreeOrder1 presets are well-formed', () {
    final m = F0856HFractalTreeOrder1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0856HFractalTreeOrder1 metadata is consistent', () {
    final m = F0856HFractalTreeOrder1();
    expect(m.metadata.id, m.id);
  });
}
