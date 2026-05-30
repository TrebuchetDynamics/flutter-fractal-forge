// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1121_fractal_flame_v20_cosine/f1121_fractal_flame_v20_cosine_module.dart';

void main() {
  test('F1121FractalFlameV20Cosine instantiates', () {
    final m = F1121FractalFlameV20Cosine();
    expect(m.id, 'f1121_fractal_flame_v20_cosine');
    expect(m.shader, 'shaders/f1121_fractal_flame_v20_cosine_gpu.frag');
  });

  test('F1121FractalFlameV20Cosine presets are well-formed', () {
    final m = F1121FractalFlameV20Cosine();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1121FractalFlameV20Cosine metadata is consistent', () {
    final m = F1121FractalFlameV20Cosine();
    expect(m.metadata.id, m.id);
  });
}
