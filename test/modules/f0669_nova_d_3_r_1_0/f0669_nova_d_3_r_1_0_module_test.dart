// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0669_nova_d_3_r_1_0/f0669_nova_d_3_r_1_0_module.dart';

void main() {
  test('F0669NovaD3R10 instantiates', () {
    final m = F0669NovaD3R10();
    expect(m.id, 'f0669_nova_d_3_r_1_0');
    expect(m.shader, 'shaders/f0669_nova_d_3_r_1_0_gpu.frag');
  });

  test('F0669NovaD3R10 presets are well-formed', () {
    final m = F0669NovaD3R10();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0669NovaD3R10 metadata is consistent', () {
    final m = F0669NovaD3R10();
    expect(m.metadata.id, m.id);
  });
}
