// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0516_exp_i_z_c/f0516_exp_i_z_c_module.dart';

void main() {
  test('F0516ExpIZC instantiates', () {
    final m = F0516ExpIZC();
    expect(m.id, 'f0516_exp_i_z_c');
    expect(m.shader, 'shaders/f0516_exp_i_z_c_gpu.frag');
  });

  test('F0516ExpIZC presets are well-formed', () {
    final m = F0516ExpIZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0516ExpIZC metadata is consistent', () {
    final m = F0516ExpIZC();
    expect(m.metadata.id, m.id);
  });
}
