// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0513_sec_z_c/f0513_sec_z_c_module.dart';

void main() {
  test('F0513SecZC instantiates', () {
    final m = F0513SecZC();
    expect(m.id, 'f0513_sec_z_c');
    expect(m.shader, 'shaders/f0513_sec_z_c_gpu.frag');
  });

  test('F0513SecZC presets are well-formed', () {
    final m = F0513SecZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0513SecZC metadata is consistent', () {
    final m = F0513SecZC();
    expect(m.metadata.id, m.id);
  });
}
