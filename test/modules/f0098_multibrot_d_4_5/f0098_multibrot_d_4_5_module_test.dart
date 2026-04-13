// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0098_multibrot_d_4_5/f0098_multibrot_d_4_5_module.dart';

void main() {
  test('F0098MultibrotD45 instantiates', () {
    final m = F0098MultibrotD45();
    expect(m.id, 'f0098_multibrot_d_4_5');
    expect(m.shader, 'shaders/f0098_multibrot_d_4_5_gpu.frag');
  });

  test('F0098MultibrotD45 presets are well-formed', () {
    final m = F0098MultibrotD45();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0098MultibrotD45 metadata is consistent', () {
    final m = F0098MultibrotD45();
    expect(m.metadata.id, m.id);
  });
}
