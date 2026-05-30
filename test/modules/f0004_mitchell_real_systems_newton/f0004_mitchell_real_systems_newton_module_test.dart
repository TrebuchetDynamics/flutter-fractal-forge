// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0004_mitchell_real_systems_newton/f0004_mitchell_real_systems_newton_module.dart';

void main() {
  test('F0004MitchellRealSystemsNewton instantiates', () {
    final m = F0004MitchellRealSystemsNewton();
    expect(m.id, 'f0004_mitchell_real_systems_newton');
    expect(m.shader, 'shaders/f0004_mitchell_real_systems_newton_gpu.frag');
  });

  test('F0004MitchellRealSystemsNewton presets are well-formed', () {
    final m = F0004MitchellRealSystemsNewton();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0004MitchellRealSystemsNewton metadata is consistent', () {
    final m = F0004MitchellRealSystemsNewton();
    expect(m.metadata.id, m.id);
  });
}
