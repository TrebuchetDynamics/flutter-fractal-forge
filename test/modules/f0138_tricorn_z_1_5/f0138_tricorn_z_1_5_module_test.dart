// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0138_tricorn_z_1_5/f0138_tricorn_z_1_5_module.dart';

void main() {
  test('F0138TricornZ15 instantiates', () {
    final m = F0138TricornZ15();
    expect(m.id, 'f0138_tricorn_z_1_5');
    expect(m.shader, 'shaders/f0138_tricorn_z_1_5_gpu.frag');
  });

  test('F0138TricornZ15 presets are well-formed', () {
    final m = F0138TricornZ15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0138TricornZ15 metadata is consistent', () {
    final m = F0138TricornZ15();
    expect(m.metadata.id, m.id);
  });
}
