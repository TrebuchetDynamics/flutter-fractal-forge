// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1135_fractal_flame_v34_blur/f1135_fractal_flame_v34_blur_module.dart';

void main() {
  test('F1135FractalFlameV34Blur instantiates', () {
    final m = F1135FractalFlameV34Blur();
    expect(m.id, 'f1135_fractal_flame_v34_blur');
    expect(m.shader, 'shaders/f1135_fractal_flame_v34_blur_gpu.frag');
  });

  test('F1135FractalFlameV34Blur presets are well-formed', () {
    final m = F1135FractalFlameV34Blur();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1135FractalFlameV34Blur metadata is consistent', () {
    final m = F1135FractalFlameV34Blur();
    expect(m.metadata.id, m.id);
  });
}
