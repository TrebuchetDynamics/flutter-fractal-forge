// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0541_quaternion_julia_0_125_0_256_0_847_0_089/f0541_quaternion_julia_0_125_0_256_0_847_0_089_module.dart';

void main() {
  test('F0541QuaternionJulia0125025608470089 instantiates', () {
    final m = F0541QuaternionJulia0125025608470089();
    expect(m.id, 'f0541_quaternion_julia_0_125_0_256_0_847_0_089');
    expect(m.shader, 'shaders/f0541_quaternion_julia_0_125_0_256_0_847_0_089_gpu.frag');
  });

  test('F0541QuaternionJulia0125025608470089 presets are well-formed', () {
    final m = F0541QuaternionJulia0125025608470089();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0541QuaternionJulia0125025608470089 metadata is consistent', () {
    final m = F0541QuaternionJulia0125025608470089();
    expect(m.metadata.id, m.id);
  });
}
