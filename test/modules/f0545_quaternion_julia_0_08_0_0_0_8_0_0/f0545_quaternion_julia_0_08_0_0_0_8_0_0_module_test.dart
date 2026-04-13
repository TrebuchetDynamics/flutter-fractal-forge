// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0545_quaternion_julia_0_08_0_0_0_8_0_0/f0545_quaternion_julia_0_08_0_0_0_8_0_0_module.dart';

void main() {
  test('F0545QuaternionJulia008000800 instantiates', () {
    final m = F0545QuaternionJulia008000800();
    expect(m.id, 'f0545_quaternion_julia_0_08_0_0_0_8_0_0');
    expect(m.shader, 'shaders/f0545_quaternion_julia_0_08_0_0_0_8_0_0_gpu.frag');
  });

  test('F0545QuaternionJulia008000800 presets are well-formed', () {
    final m = F0545QuaternionJulia008000800();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0545QuaternionJulia008000800 metadata is consistent', () {
    final m = F0545QuaternionJulia008000800();
    expect(m.metadata.id, m.id);
  });
}
