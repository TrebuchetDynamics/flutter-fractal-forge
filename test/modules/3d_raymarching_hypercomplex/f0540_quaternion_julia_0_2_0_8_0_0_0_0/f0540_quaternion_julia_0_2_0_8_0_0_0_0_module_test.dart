// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0540_quaternion_julia_0_2_0_8_0_0_0_0/f0540_quaternion_julia_0_2_0_8_0_0_0_0_module.dart';

void main() {
  test('F0540QuaternionJulia02080000 instantiates', () {
    final m = F0540QuaternionJulia02080000();
    expect(m.id, 'f0540_quaternion_julia_0_2_0_8_0_0_0_0');
    expect(m.shader, 'shaders/f0540_quaternion_julia_0_2_0_8_0_0_0_0_gpu.frag');
  });

  test('F0540QuaternionJulia02080000 presets are well-formed', () {
    final m = F0540QuaternionJulia02080000();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0540QuaternionJulia02080000 metadata is consistent', () {
    final m = F0540QuaternionJulia02080000();
    expect(m.metadata.id, m.id);
  });
}
