// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1118_fractal_flame_v17_popcorn/f1118_fractal_flame_v17_popcorn_module.dart';

void main() {
  test('F1118FractalFlameV17Popcorn instantiates', () {
    final m = F1118FractalFlameV17Popcorn();
    expect(m.id, 'f1118_fractal_flame_v17_popcorn');
    expect(m.shader, 'shaders/f1118_fractal_flame_v17_popcorn_gpu.frag');
  });

  test('F1118FractalFlameV17Popcorn presets are well-formed', () {
    final m = F1118FractalFlameV17Popcorn();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1118FractalFlameV17Popcorn metadata is consistent', () {
    final m = F1118FractalFlameV17Popcorn();
    expect(m.metadata.id, m.id);
  });
}
