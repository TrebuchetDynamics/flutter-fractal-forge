// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0003_mitchell_alternating_equations_newton/f0003_mitchell_alternating_equations_newton_module.dart';

void main() {
  test('F0003MitchellAlternatingEquationsNewton instantiates', () {
    final m = F0003MitchellAlternatingEquationsNewton();
    expect(m.id, 'f0003_mitchell_alternating_equations_newton');
    expect(m.shader,
        'shaders/f0003_mitchell_alternating_equations_newton_gpu.frag');
  });

  test('F0003MitchellAlternatingEquationsNewton presets are well-formed', () {
    final m = F0003MitchellAlternatingEquationsNewton();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0003MitchellAlternatingEquationsNewton metadata is consistent', () {
    final m = F0003MitchellAlternatingEquationsNewton();
    expect(m.metadata.id, m.id);
  });
}
