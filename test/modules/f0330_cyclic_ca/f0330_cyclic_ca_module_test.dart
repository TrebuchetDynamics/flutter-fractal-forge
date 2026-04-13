// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0330_cyclic_ca/f0330_cyclic_ca_module.dart';

void main() {
  test('F0330CyclicCa instantiates', () {
    final m = F0330CyclicCa();
    expect(m.id, 'f0330_cyclic_ca');
    expect(m.shader, 'shaders/f0330_cyclic_ca_gpu.frag');
  });

  test('F0330CyclicCa presets are well-formed', () {
    final m = F0330CyclicCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0330CyclicCa metadata is consistent', () {
    final m = F0330CyclicCa();
    expect(m.metadata.id, m.id);
  });
}
