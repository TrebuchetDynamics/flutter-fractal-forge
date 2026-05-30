// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0293_fractal_flame_ifs_linear/f0293_fractal_flame_ifs_linear_module.dart';

void main() {
  test('F0293FractalFlameIfsLinear instantiates', () {
    final m = F0293FractalFlameIfsLinear();
    expect(m.id, 'f0293_fractal_flame_ifs_linear');
    expect(m.shader, 'shaders/f0293_fractal_flame_ifs_linear_gpu.frag');
  });

  test('F0293FractalFlameIfsLinear presets are well-formed', () {
    final m = F0293FractalFlameIfsLinear();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0293FractalFlameIfsLinear metadata is consistent', () {
    final m = F0293FractalFlameIfsLinear();
    expect(m.metadata.id, m.id);
  });
}
