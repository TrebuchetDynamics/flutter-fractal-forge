// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1114_fractal_flame_v13_julia/f1114_fractal_flame_v13_julia_module.dart';

void main() {
  test('F1114FractalFlameV13Julia instantiates', () {
    final m = F1114FractalFlameV13Julia();
    expect(m.id, 'f1114_fractal_flame_v13_julia');
    expect(m.shader, 'shaders/f1114_fractal_flame_v13_julia_gpu.frag');
  });

  test('F1114FractalFlameV13Julia presets are well-formed', () {
    final m = F1114FractalFlameV13Julia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1114FractalFlameV13Julia metadata is consistent', () {
    final m = F1114FractalFlameV13Julia();
    expect(m.metadata.id, m.id);
  });
}
