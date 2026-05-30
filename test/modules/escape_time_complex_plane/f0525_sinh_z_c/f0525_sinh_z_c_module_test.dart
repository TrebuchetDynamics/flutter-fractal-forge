// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0525_sinh_z_c/f0525_sinh_z_c_module.dart';

void main() {
  test('F0525SinhZC instantiates', () {
    final m = F0525SinhZC();
    expect(m.id, 'f0525_sinh_z_c');
    expect(m.shader, 'shaders/f0525_sinh_z_c_gpu.frag');
  });

  test('F0525SinhZC presets are well-formed', () {
    final m = F0525SinhZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0525SinhZC metadata is consistent', () {
    final m = F0525SinhZC();
    expect(m.metadata.id, m.id);
  });
}
