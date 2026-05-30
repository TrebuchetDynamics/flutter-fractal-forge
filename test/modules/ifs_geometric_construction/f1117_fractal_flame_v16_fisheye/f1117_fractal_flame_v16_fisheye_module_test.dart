// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1117_fractal_flame_v16_fisheye/f1117_fractal_flame_v16_fisheye_module.dart';

void main() {
  test('F1117FractalFlameV16Fisheye instantiates', () {
    final m = F1117FractalFlameV16Fisheye();
    expect(m.id, 'f1117_fractal_flame_v16_fisheye');
    expect(m.shader, 'shaders/f1117_fractal_flame_v16_fisheye_gpu.frag');
  });

  test('F1117FractalFlameV16Fisheye presets are well-formed', () {
    final m = F1117FractalFlameV16Fisheye();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1117FractalFlameV16Fisheye metadata is consistent', () {
    final m = F1117FractalFlameV16Fisheye();
    expect(m.metadata.id, m.id);
  });
}
