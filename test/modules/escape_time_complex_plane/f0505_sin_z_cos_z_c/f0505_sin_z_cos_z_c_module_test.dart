// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0505_sin_z_cos_z_c/f0505_sin_z_cos_z_c_module.dart';

void main() {
  test('F0505SinZCosZC instantiates', () {
    final m = F0505SinZCosZC();
    expect(m.id, 'f0505_sin_z_cos_z_c');
    expect(m.shader, 'shaders/f0505_sin_z_cos_z_c_gpu.frag');
  });

  test('F0505SinZCosZC presets are well-formed', () {
    final m = F0505SinZCosZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0505SinZCosZC metadata is consistent', () {
    final m = F0505SinZCosZC();
    expect(m.metadata.id, m.id);
  });
}
