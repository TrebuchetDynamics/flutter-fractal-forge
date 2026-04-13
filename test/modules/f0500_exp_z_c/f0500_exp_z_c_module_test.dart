// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0500_exp_z_c/f0500_exp_z_c_module.dart';

void main() {
  test('F0500ExpZC instantiates', () {
    final m = F0500ExpZC();
    expect(m.id, 'f0500_exp_z_c');
    expect(m.shader, 'shaders/f0500_exp_z_c_gpu.frag');
  });

  test('F0500ExpZC presets are well-formed', () {
    final m = F0500ExpZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0500ExpZC metadata is consistent', () {
    final m = F0500ExpZC();
    expect(m.metadata.id, m.id);
  });
}
