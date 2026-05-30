// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1180_smooth_iteration_coloring_continuous/f1180_smooth_iteration_coloring_continuous_module.dart';

void main() {
  test('F1180SmoothIterationColoringContinuous instantiates', () {
    final m = F1180SmoothIterationColoringContinuous();
    expect(m.id, 'f1180_smooth_iteration_coloring_continuous');
    expect(m.shader,
        'shaders/f1180_smooth_iteration_coloring_continuous_gpu.frag');
  });

  test('F1180SmoothIterationColoringContinuous presets are well-formed', () {
    final m = F1180SmoothIterationColoringContinuous();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1180SmoothIterationColoringContinuous metadata is consistent', () {
    final m = F1180SmoothIterationColoringContinuous();
    expect(m.metadata.id, m.id);
  });
}
