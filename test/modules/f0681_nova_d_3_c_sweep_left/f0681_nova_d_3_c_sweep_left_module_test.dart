// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0681_nova_d_3_c_sweep_left/f0681_nova_d_3_c_sweep_left_module.dart';

void main() {
  test('F0681NovaD3CSweepLeft instantiates', () {
    final m = F0681NovaD3CSweepLeft();
    expect(m.id, 'f0681_nova_d_3_c_sweep_left');
    expect(m.shader, 'shaders/f0681_nova_d_3_c_sweep_left_gpu.frag');
  });

  test('F0681NovaD3CSweepLeft presets are well-formed', () {
    final m = F0681NovaD3CSweepLeft();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0681NovaD3CSweepLeft metadata is consistent', () {
    final m = F0681NovaD3CSweepLeft();
    expect(m.metadata.id, m.id);
  });
}
