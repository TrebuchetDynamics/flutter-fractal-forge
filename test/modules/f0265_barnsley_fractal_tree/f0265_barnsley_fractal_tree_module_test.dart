// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0265_barnsley_fractal_tree/f0265_barnsley_fractal_tree_module.dart';

void main() {
  test('F0265BarnsleyFractalTree instantiates', () {
    final m = F0265BarnsleyFractalTree();
    expect(m.id, 'f0265_barnsley_fractal_tree');
    expect(m.shader, 'shaders/f0265_barnsley_fractal_tree_gpu.frag');
  });

  test('F0265BarnsleyFractalTree presets are well-formed', () {
    final m = F0265BarnsleyFractalTree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0265BarnsleyFractalTree metadata is consistent', () {
    final m = F0265BarnsleyFractalTree();
    expect(m.metadata.id, m.id);
  });
}
