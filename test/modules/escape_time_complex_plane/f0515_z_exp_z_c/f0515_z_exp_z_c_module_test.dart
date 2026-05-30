// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0515_z_exp_z_c/f0515_z_exp_z_c_module.dart';

void main() {
  test('F0515ZExpZC instantiates', () {
    final m = F0515ZExpZC();
    expect(m.id, 'f0515_z_exp_z_c');
    expect(m.shader, 'shaders/f0515_z_exp_z_c_gpu.frag');
  });

  test('F0515ZExpZC presets are well-formed', () {
    final m = F0515ZExpZC();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0515ZExpZC metadata is consistent', () {
    final m = F0515ZExpZC();
    expect(m.metadata.id, m.id);
  });
}
