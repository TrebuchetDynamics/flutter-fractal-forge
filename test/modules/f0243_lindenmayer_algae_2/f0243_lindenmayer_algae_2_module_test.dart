// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0243_lindenmayer_algae_2/f0243_lindenmayer_algae_2_module.dart';

void main() {
  test('F0243LindenmayerAlgae2 instantiates', () {
    final m = F0243LindenmayerAlgae2();
    expect(m.id, 'f0243_lindenmayer_algae_2');
    expect(m.shader, 'shaders/f0243_lindenmayer_algae_2_gpu.frag');
  });

  test('F0243LindenmayerAlgae2 presets are well-formed', () {
    final m = F0243LindenmayerAlgae2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0243LindenmayerAlgae2 metadata is consistent', () {
    final m = F0243LindenmayerAlgae2();
    expect(m.metadata.id, m.id);
  });
}
