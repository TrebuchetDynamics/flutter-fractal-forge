// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0723_ammann_rhombic_a1/f0723_ammann_rhombic_a1_module.dart';

void main() {
  test('F0723AmmannRhombicA1 instantiates', () {
    final m = F0723AmmannRhombicA1();
    expect(m.id, 'f0723_ammann_rhombic_a1');
    expect(m.shader, 'shaders/f0723_ammann_rhombic_a1_gpu.frag');
  });

  test('F0723AmmannRhombicA1 presets are well-formed', () {
    final m = F0723AmmannRhombicA1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0723AmmannRhombicA1 metadata is consistent', () {
    final m = F0723AmmannRhombicA1();
    expect(m.metadata.id, m.id);
  });
}
