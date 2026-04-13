// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0668_nova_d_2_r_1_5/f0668_nova_d_2_r_1_5_module.dart';

void main() {
  test('F0668NovaD2R15 instantiates', () {
    final m = F0668NovaD2R15();
    expect(m.id, 'f0668_nova_d_2_r_1_5');
    expect(m.shader, 'shaders/f0668_nova_d_2_r_1_5_gpu.frag');
  });

  test('F0668NovaD2R15 presets are well-formed', () {
    final m = F0668NovaD2R15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0668NovaD2R15 metadata is consistent', () {
    final m = F0668NovaD2R15();
    expect(m.metadata.id, m.id);
  });
}
