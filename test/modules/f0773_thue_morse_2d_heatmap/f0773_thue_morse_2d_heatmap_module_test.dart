// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/number_theory_fractals/f0773_thue_morse_2d_heatmap/f0773_thue_morse_2d_heatmap_module.dart';

void main() {
  test('F0773ThueMorse2dHeatmap instantiates', () {
    final m = F0773ThueMorse2dHeatmap();
    expect(m.id, 'f0773_thue_morse_2d_heatmap');
    expect(m.shader, 'shaders/f0773_thue_morse_2d_heatmap_gpu.frag');
  });

  test('F0773ThueMorse2dHeatmap presets are well-formed', () {
    final m = F0773ThueMorse2dHeatmap();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0773ThueMorse2dHeatmap metadata is consistent', () {
    final m = F0773ThueMorse2dHeatmap();
    expect(m.metadata.id, m.id);
  });
}
