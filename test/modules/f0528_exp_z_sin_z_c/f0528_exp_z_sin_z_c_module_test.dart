// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0528_exp_z_sin_z_c/f0528_exp_z_sin_z_c_module.dart';

void main() {
  test('F0528ExpZSinZC instantiates', () {
    final m = F0528ExpZSinZC();
    expect(m.id, 'f0528_exp_z_sin_z_c');
    expect(m.shader, 'shaders/f0528_exp_z_sin_z_c_gpu.frag');
  });

  test('F0528ExpZSinZC presets are well-formed', () {
    final m = F0528ExpZSinZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0528ExpZSinZC metadata is consistent', () {
    final m = F0528ExpZSinZC();
    expect(m.metadata.id, m.id);
  });
}
