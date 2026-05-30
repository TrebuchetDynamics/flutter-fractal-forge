// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0522_exp_z_z_c/f0522_exp_z_z_c_module.dart';

void main() {
  test('F0522ExpZZC instantiates', () {
    final m = F0522ExpZZC();
    expect(m.id, 'f0522_exp_z_z_c');
    expect(m.shader, 'shaders/f0522_exp_z_z_c_gpu.frag');
  });

  test('F0522ExpZZC presets are well-formed', () {
    final m = F0522ExpZZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0522ExpZZC metadata is consistent', () {
    final m = F0522ExpZZC();
    expect(m.metadata.id, m.id);
  });
}
