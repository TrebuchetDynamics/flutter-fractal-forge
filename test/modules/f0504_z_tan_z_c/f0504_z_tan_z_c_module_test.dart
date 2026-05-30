// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0504_z_tan_z_c/f0504_z_tan_z_c_module.dart';

void main() {
  test('F0504ZTanZC instantiates', () {
    final m = F0504ZTanZC();
    expect(m.id, 'f0504_z_tan_z_c');
    expect(m.shader, 'shaders/f0504_z_tan_z_c_gpu.frag');
  });

  test('F0504ZTanZC presets are well-formed', () {
    final m = F0504ZTanZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0504ZTanZC metadata is consistent', () {
    final m = F0504ZTanZC();
    expect(m.metadata.id, m.id);
  });
}
