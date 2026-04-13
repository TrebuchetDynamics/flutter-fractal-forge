// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0510_tan_z_c/f0510_tan_z_c_module.dart';

void main() {
  test('F0510TanZC instantiates', () {
    final m = F0510TanZC();
    expect(m.id, 'f0510_tan_z_c');
    expect(m.shader, 'shaders/f0510_tan_z_c_gpu.frag');
  });

  test('F0510TanZC presets are well-formed', () {
    final m = F0510TanZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0510TanZC metadata is consistent', () {
    final m = F0510TanZC();
    expect(m.metadata.id, m.id);
  });
}
