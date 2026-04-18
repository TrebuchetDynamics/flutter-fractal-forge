// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1136_fractal_flame_v35_gaussian_blur/f1136_fractal_flame_v35_gaussian_blur_module.dart';

void main() {
  test('F1136FractalFlameV35GaussianBlur instantiates', () {
    final m = F1136FractalFlameV35GaussianBlur();
    expect(m.id, 'f1136_fractal_flame_v35_gaussian_blur');
    expect(m.shader, 'shaders/f1136_fractal_flame_v35_gaussian_blur_gpu.frag');
  });

  test('F1136FractalFlameV35GaussianBlur presets are well-formed', () {
    final m = F1136FractalFlameV35GaussianBlur();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1136FractalFlameV35GaussianBlur metadata is consistent', () {
    final m = F1136FractalFlameV35GaussianBlur();
    expect(m.metadata.id, m.id);
  });
}
