// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1182_curvature_estimation_coloring/f1182_curvature_estimation_coloring_module.dart';

void main() {
  test('F1182CurvatureEstimationColoring instantiates', () {
    final m = F1182CurvatureEstimationColoring();
    expect(m.id, 'f1182_curvature_estimation_coloring');
    expect(m.shader, 'shaders/f1182_curvature_estimation_coloring_gpu.frag');
  });

  test('F1182CurvatureEstimationColoring presets are well-formed', () {
    final m = F1182CurvatureEstimationColoring();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1182CurvatureEstimationColoring metadata is consistent', () {
    final m = F1182CurvatureEstimationColoring();
    expect(m.metadata.id, m.id);
  });
}
