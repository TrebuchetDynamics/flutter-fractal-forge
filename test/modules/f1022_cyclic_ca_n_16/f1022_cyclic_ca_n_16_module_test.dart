// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1022_cyclic_ca_n_16/f1022_cyclic_ca_n_16_module.dart';

void main() {
  test('F1022CyclicCaN16 instantiates', () {
    final m = F1022CyclicCaN16();
    expect(m.id, 'f1022_cyclic_ca_n_16');
    expect(m.shader, 'shaders/f1022_cyclic_ca_n_16_gpu.frag');
  });

  test('F1022CyclicCaN16 presets are well-formed', () {
    final m = F1022CyclicCaN16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1022CyclicCaN16 metadata is consistent', () {
    final m = F1022CyclicCaN16();
    expect(m.metadata.id, m.id);
  });
}
