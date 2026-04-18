// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1138_fractal_flame_v37_pie/f1138_fractal_flame_v37_pie_module.dart';

void main() {
  test('F1138FractalFlameV37Pie instantiates', () {
    final m = F1138FractalFlameV37Pie();
    expect(m.id, 'f1138_fractal_flame_v37_pie');
    expect(m.shader, 'shaders/f1138_fractal_flame_v37_pie_gpu.frag');
  });

  test('F1138FractalFlameV37Pie presets are well-formed', () {
    final m = F1138FractalFlameV37Pie();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1138FractalFlameV37Pie metadata is consistent', () {
    final m = F1138FractalFlameV37Pie();
    expect(m.metadata.id, m.id);
  });
}
