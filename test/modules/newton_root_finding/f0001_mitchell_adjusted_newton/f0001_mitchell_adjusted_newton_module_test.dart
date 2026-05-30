// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0001_mitchell_adjusted_newton/f0001_mitchell_adjusted_newton_module.dart';

void main() {
  test('F0001MitchellAdjustedNewton instantiates', () {
    final m = F0001MitchellAdjustedNewton();
    expect(m.id, 'f0001_mitchell_adjusted_newton');
    expect(m.shader, 'shaders/f0001_mitchell_adjusted_newton_gpu.frag');
  });

  test('F0001MitchellAdjustedNewton presets are well-formed', () {
    final m = F0001MitchellAdjustedNewton();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0001MitchellAdjustedNewton metadata is consistent', () {
    final m = F0001MitchellAdjustedNewton();
    expect(m.metadata.id, m.id);
  });
}
