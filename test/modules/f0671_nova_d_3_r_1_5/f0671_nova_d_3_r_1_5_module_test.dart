// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0671_nova_d_3_r_1_5/f0671_nova_d_3_r_1_5_module.dart';

void main() {
  test('F0671NovaD3R15 instantiates', () {
    final m = F0671NovaD3R15();
    expect(m.id, 'f0671_nova_d_3_r_1_5');
    expect(m.shader, 'shaders/f0671_nova_d_3_r_1_5_gpu.frag');
  });

  test('F0671NovaD3R15 presets are well-formed', () {
    final m = F0671NovaD3R15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0671NovaD3R15 metadata is consistent', () {
    final m = F0671NovaD3R15();
    expect(m.metadata.id, m.id);
  });
}
