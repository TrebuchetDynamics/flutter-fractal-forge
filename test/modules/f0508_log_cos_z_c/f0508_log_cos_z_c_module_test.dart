// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0508_log_cos_z_c/f0508_log_cos_z_c_module.dart';

void main() {
  test('F0508LogCosZC instantiates', () {
    final m = F0508LogCosZC();
    expect(m.id, 'f0508_log_cos_z_c');
    expect(m.shader, 'shaders/f0508_log_cos_z_c_gpu.frag');
  });

  test('F0508LogCosZC presets are well-formed', () {
    final m = F0508LogCosZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0508LogCosZC metadata is consistent', () {
    final m = F0508LogCosZC();
    expect(m.metadata.id, m.id);
  });
}
