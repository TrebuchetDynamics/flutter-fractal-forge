// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1021_cyclic_ca_n_4/f1021_cyclic_ca_n_4_module.dart';

void main() {
  test('F1021CyclicCaN4 instantiates', () {
    final m = F1021CyclicCaN4();
    expect(m.id, 'f1021_cyclic_ca_n_4');
    expect(m.shader, 'shaders/f1021_cyclic_ca_n_4_gpu.frag');
  });

  test('F1021CyclicCaN4 presets are well-formed', () {
    final m = F1021CyclicCaN4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1021CyclicCaN4 metadata is consistent', () {
    final m = F1021CyclicCaN4();
    expect(m.metadata.id, m.id);
  });
}
