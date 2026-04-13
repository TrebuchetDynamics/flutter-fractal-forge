// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0675_nova_d_5_r_0_8/f0675_nova_d_5_r_0_8_module.dart';

void main() {
  test('F0675NovaD5R08 instantiates', () {
    final m = F0675NovaD5R08();
    expect(m.id, 'f0675_nova_d_5_r_0_8');
    expect(m.shader, 'shaders/f0675_nova_d_5_r_0_8_gpu.frag');
  });

  test('F0675NovaD5R08 presets are well-formed', () {
    final m = F0675NovaD5R08();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0675NovaD5R08 metadata is consistent', () {
    final m = F0675NovaD5R08();
    expect(m.metadata.id, m.id);
  });
}
