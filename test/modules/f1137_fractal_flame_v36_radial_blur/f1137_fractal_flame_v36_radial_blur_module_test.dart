// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1137_fractal_flame_v36_radial_blur/f1137_fractal_flame_v36_radial_blur_module.dart';

void main() {
  test('F1137FractalFlameV36RadialBlur instantiates', () {
    final m = F1137FractalFlameV36RadialBlur();
    expect(m.id, 'f1137_fractal_flame_v36_radial_blur');
    expect(m.shader, 'shaders/f1137_fractal_flame_v36_radial_blur_gpu.frag');
  });

  test('F1137FractalFlameV36RadialBlur presets are well-formed', () {
    final m = F1137FractalFlameV36RadialBlur();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1137FractalFlameV36RadialBlur metadata is consistent', () {
    final m = F1137FractalFlameV36RadialBlur();
    expect(m.metadata.id, m.id);
  });
}
