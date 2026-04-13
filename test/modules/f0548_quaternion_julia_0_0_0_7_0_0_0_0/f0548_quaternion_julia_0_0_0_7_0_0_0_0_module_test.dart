// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0548_quaternion_julia_0_0_0_7_0_0_0_0/f0548_quaternion_julia_0_0_0_7_0_0_0_0_module.dart';

void main() {
  test('F0548QuaternionJulia00070000 instantiates', () {
    final m = F0548QuaternionJulia00070000();
    expect(m.id, 'f0548_quaternion_julia_0_0_0_7_0_0_0_0');
    expect(m.shader, 'shaders/f0548_quaternion_julia_0_0_0_7_0_0_0_0_gpu.frag');
  });

  test('F0548QuaternionJulia00070000 presets are well-formed', () {
    final m = F0548QuaternionJulia00070000();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0548QuaternionJulia00070000 metadata is consistent', () {
    final m = F0548QuaternionJulia00070000();
    expect(m.metadata.id, m.id);
  });
}
