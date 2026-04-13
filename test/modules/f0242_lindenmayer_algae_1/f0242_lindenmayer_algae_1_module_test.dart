// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0242_lindenmayer_algae_1/f0242_lindenmayer_algae_1_module.dart';

void main() {
  test('F0242LindenmayerAlgae1 instantiates', () {
    final m = F0242LindenmayerAlgae1();
    expect(m.id, 'f0242_lindenmayer_algae_1');
    expect(m.shader, 'shaders/f0242_lindenmayer_algae_1_gpu.frag');
  });

  test('F0242LindenmayerAlgae1 presets are well-formed', () {
    final m = F0242LindenmayerAlgae1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0242LindenmayerAlgae1 metadata is consistent', () {
    final m = F0242LindenmayerAlgae1();
    expect(m.metadata.id, m.id);
  });
}
