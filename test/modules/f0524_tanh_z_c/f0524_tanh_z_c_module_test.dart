// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0524_tanh_z_c/f0524_tanh_z_c_module.dart';

void main() {
  test('F0524TanhZC instantiates', () {
    final m = F0524TanhZC();
    expect(m.id, 'f0524_tanh_z_c');
    expect(m.shader, 'shaders/f0524_tanh_z_c_gpu.frag');
  });

  test('F0524TanhZC presets are well-formed', () {
    final m = F0524TanhZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0524TanhZC metadata is consistent', () {
    final m = F0524TanhZC();
    expect(m.metadata.id, m.id);
  });
}
