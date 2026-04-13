// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0680_nova_d_10_r_1_0/f0680_nova_d_10_r_1_0_module.dart';

void main() {
  test('F0680NovaD10R10 instantiates', () {
    final m = F0680NovaD10R10();
    expect(m.id, 'f0680_nova_d_10_r_1_0');
    expect(m.shader, 'shaders/f0680_nova_d_10_r_1_0_gpu.frag');
  });

  test('F0680NovaD10R10 presets are well-formed', () {
    final m = F0680NovaD10R10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0680NovaD10R10 metadata is consistent', () {
    final m = F0680NovaD10R10();
    expect(m.metadata.id, m.id);
  });
}
