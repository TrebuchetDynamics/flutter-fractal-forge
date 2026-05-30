// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0512_csc_z_c/f0512_csc_z_c_module.dart';

void main() {
  test('F0512CscZC instantiates', () {
    final m = F0512CscZC();
    expect(m.id, 'f0512_csc_z_c');
    expect(m.shader, 'shaders/f0512_csc_z_c_gpu.frag');
  });

  test('F0512CscZC presets are well-formed', () {
    final m = F0512CscZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0512CscZC metadata is consistent', () {
    final m = F0512CscZC();
    expect(m.metadata.id, m.id);
  });
}
