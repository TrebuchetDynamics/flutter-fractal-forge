// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0499_cos_z_c/f0499_cos_z_c_module.dart';

void main() {
  test('F0499CosZC instantiates', () {
    final m = F0499CosZC();
    expect(m.id, 'f0499_cos_z_c');
    expect(m.shader, 'shaders/f0499_cos_z_c_gpu.frag');
  });

  test('F0499CosZC presets are well-formed', () {
    final m = F0499CosZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0499CosZC metadata is consistent', () {
    final m = F0499CosZC();
    expect(m.metadata.id, m.id);
  });
}
