// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0875_fern_asymmetric/f0875_fern_asymmetric_module.dart';

void main() {
  test('F0875FernAsymmetric instantiates', () {
    final m = F0875FernAsymmetric();
    expect(m.id, 'f0875_fern_asymmetric');
    expect(m.shader, 'shaders/f0875_fern_asymmetric_gpu.frag');
  });

  test('F0875FernAsymmetric presets are well-formed', () {
    final m = F0875FernAsymmetric();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0875FernAsymmetric metadata is consistent', () {
    final m = F0875FernAsymmetric();
    expect(m.metadata.id, m.id);
  });
}
