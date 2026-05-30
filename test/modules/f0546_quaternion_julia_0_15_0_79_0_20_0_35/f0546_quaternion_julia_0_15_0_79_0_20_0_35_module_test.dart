// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0546_quaternion_julia_0_15_0_79_0_20_0_35/f0546_quaternion_julia_0_15_0_79_0_20_0_35_module.dart';

void main() {
  test('F0546QuaternionJulia015079020035 instantiates', () {
    final m = F0546QuaternionJulia015079020035();
    expect(m.id, 'f0546_quaternion_julia_0_15_0_79_0_20_0_35');
    expect(m.shader,
        'shaders/f0546_quaternion_julia_0_15_0_79_0_20_0_35_gpu.frag');
  });

  test('F0546QuaternionJulia015079020035 presets are well-formed', () {
    final m = F0546QuaternionJulia015079020035();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0546QuaternionJulia015079020035 metadata is consistent', () {
    final m = F0546QuaternionJulia015079020035();
    expect(m.metadata.id, m.id);
  });
}
