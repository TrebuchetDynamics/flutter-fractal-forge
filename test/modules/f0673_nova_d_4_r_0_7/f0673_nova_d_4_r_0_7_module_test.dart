// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0673_nova_d_4_r_0_7/f0673_nova_d_4_r_0_7_module.dart';

void main() {
  test('F0673NovaD4R07 instantiates', () {
    final m = F0673NovaD4R07();
    expect(m.id, 'f0673_nova_d_4_r_0_7');
    expect(m.shader, 'shaders/f0673_nova_d_4_r_0_7_gpu.frag');
  });

  test('F0673NovaD4R07 presets are well-formed', () {
    final m = F0673NovaD4R07();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0673NovaD4R07 metadata is consistent', () {
    final m = F0673NovaD4R07();
    expect(m.metadata.id, m.id);
  });
}
