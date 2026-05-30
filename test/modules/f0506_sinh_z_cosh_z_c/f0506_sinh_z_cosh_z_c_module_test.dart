// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0506_sinh_z_cosh_z_c/f0506_sinh_z_cosh_z_c_module.dart';

void main() {
  test('F0506SinhZCoshZC instantiates', () {
    final m = F0506SinhZCoshZC();
    expect(m.id, 'f0506_sinh_z_cosh_z_c');
    expect(m.shader, 'shaders/f0506_sinh_z_cosh_z_c_gpu.frag');
  });

  test('F0506SinhZCoshZC presets are well-formed', () {
    final m = F0506SinhZCoshZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0506SinhZCoshZC metadata is consistent', () {
    final m = F0506SinhZCoshZC();
    expect(m.metadata.id, m.id);
  });
}
