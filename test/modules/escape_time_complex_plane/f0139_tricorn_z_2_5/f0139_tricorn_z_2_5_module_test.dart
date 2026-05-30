// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0139_tricorn_z_2_5/f0139_tricorn_z_2_5_module.dart';

void main() {
  test('F0139TricornZ25 instantiates', () {
    final m = F0139TricornZ25();
    expect(m.id, 'f0139_tricorn_z_2_5');
    expect(m.shader, 'shaders/f0139_tricorn_z_2_5_gpu.frag');
  });

  test('F0139TricornZ25 presets are well-formed', () {
    final m = F0139TricornZ25();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0139TricornZ25 metadata is consistent', () {
    final m = F0139TricornZ25();
    expect(m.metadata.id, m.id);
  });
}
