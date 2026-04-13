// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f0002_mitchell_rotating_c_newton/f0002_mitchell_rotating_c_newton_module.dart';

void main() {
  test('F0002MitchellRotatingCNewton instantiates', () {
    final m = F0002MitchellRotatingCNewton();
    expect(m.id, 'f0002_mitchell_rotating_c_newton');
    expect(m.shader, 'shaders/f0002_mitchell_rotating_c_newton_gpu.frag');
  });

  test('F0002MitchellRotatingCNewton presets are well-formed', () {
    final m = F0002MitchellRotatingCNewton();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0002MitchellRotatingCNewton metadata is consistent', () {
    final m = F0002MitchellRotatingCNewton();
    expect(m.metadata.id, m.id);
  });
}
