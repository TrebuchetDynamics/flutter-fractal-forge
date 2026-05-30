// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/newton_root_finding/f0013_polynomiography_basic_family_iteration/f0013_polynomiography_basic_family_iteration_module.dart';

void main() {
  test('F0013PolynomiographyBasicFamilyIteration instantiates', () {
    final m = F0013PolynomiographyBasicFamilyIteration();
    expect(m.id, 'f0013_polynomiography_basic_family_iteration');
    expect(m.shader,
        'shaders/f0013_polynomiography_basic_family_iteration_gpu.frag');
  });

  test('F0013PolynomiographyBasicFamilyIteration presets are well-formed', () {
    final m = F0013PolynomiographyBasicFamilyIteration();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0013PolynomiographyBasicFamilyIteration metadata is consistent', () {
    final m = F0013PolynomiographyBasicFamilyIteration();
    expect(m.metadata.id, m.id);
  });
}
