// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0678_nova_d_8_r_1_0/f0678_nova_d_8_r_1_0_module.dart';

void main() {
  test('F0678NovaD8R10 instantiates', () {
    final m = F0678NovaD8R10();
    expect(m.id, 'f0678_nova_d_8_r_1_0');
    expect(m.shader, 'shaders/f0678_nova_d_8_r_1_0_gpu.frag');
  });

  test('F0678NovaD8R10 presets are well-formed', () {
    final m = F0678NovaD8R10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0678NovaD8R10 metadata is consistent', () {
    final m = F0678NovaD8R10();
    expect(m.metadata.id, m.id);
  });
}
