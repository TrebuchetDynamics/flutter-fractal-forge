// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0682_nova_d_3_c_sweep_right/f0682_nova_d_3_c_sweep_right_module.dart';

void main() {
  test('F0682NovaD3CSweepRight instantiates', () {
    final m = F0682NovaD3CSweepRight();
    expect(m.id, 'f0682_nova_d_3_c_sweep_right');
    expect(m.shader, 'shaders/f0682_nova_d_3_c_sweep_right_gpu.frag');
  });

  test('F0682NovaD3CSweepRight presets are well-formed', () {
    final m = F0682NovaD3CSweepRight();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0682NovaD3CSweepRight metadata is consistent', () {
    final m = F0682NovaD3CSweepRight();
    expect(m.metadata.id, m.id);
  });
}
