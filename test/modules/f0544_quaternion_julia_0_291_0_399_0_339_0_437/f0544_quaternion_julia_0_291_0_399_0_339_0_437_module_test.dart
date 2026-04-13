// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0544_quaternion_julia_0_291_0_399_0_339_0_437/f0544_quaternion_julia_0_291_0_399_0_339_0_437_module.dart';

void main() {
  test('F0544QuaternionJulia0291039903390437 instantiates', () {
    final m = F0544QuaternionJulia0291039903390437();
    expect(m.id, 'f0544_quaternion_julia_0_291_0_399_0_339_0_437');
    expect(m.shader, 'shaders/f0544_quaternion_julia_0_291_0_399_0_339_0_437_gpu.frag');
  });

  test('F0544QuaternionJulia0291039903390437 presets are well-formed', () {
    final m = F0544QuaternionJulia0291039903390437();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0544QuaternionJulia0291039903390437 metadata is consistent', () {
    final m = F0544QuaternionJulia0291039903390437();
    expect(m.metadata.id, m.id);
  });
}
