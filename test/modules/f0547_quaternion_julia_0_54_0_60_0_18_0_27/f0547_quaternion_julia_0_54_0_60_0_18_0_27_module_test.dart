// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0547_quaternion_julia_0_54_0_60_0_18_0_27/f0547_quaternion_julia_0_54_0_60_0_18_0_27_module.dart';

void main() {
  test('F0547QuaternionJulia054060018027 instantiates', () {
    final m = F0547QuaternionJulia054060018027();
    expect(m.id, 'f0547_quaternion_julia_0_54_0_60_0_18_0_27');
    expect(m.shader,
        'shaders/f0547_quaternion_julia_0_54_0_60_0_18_0_27_gpu.frag');
  });

  test('F0547QuaternionJulia054060018027 presets are well-formed', () {
    final m = F0547QuaternionJulia054060018027();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0547QuaternionJulia054060018027 metadata is consistent', () {
    final m = F0547QuaternionJulia054060018027();
    expect(m.metadata.id, m.id);
  });
}
