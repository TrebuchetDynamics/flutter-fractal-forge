// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0854_fractal_canopy_symmetric/f0854_fractal_canopy_symmetric_module.dart';

void main() {
  test('F0854FractalCanopySymmetric instantiates', () {
    final m = F0854FractalCanopySymmetric();
    expect(m.id, 'f0854_fractal_canopy_symmetric');
    expect(m.shader, 'shaders/f0854_fractal_canopy_symmetric_gpu.frag');
  });

  test('F0854FractalCanopySymmetric presets are well-formed', () {
    final m = F0854FractalCanopySymmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0854FractalCanopySymmetric metadata is consistent', () {
    final m = F0854FractalCanopySymmetric();
    expect(m.metadata.id, m.id);
  });
}
