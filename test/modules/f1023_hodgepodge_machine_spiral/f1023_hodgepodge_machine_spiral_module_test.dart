// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1023_hodgepodge_machine_spiral/f1023_hodgepodge_machine_spiral_module.dart';

void main() {
  test('F1023HodgepodgeMachineSpiral instantiates', () {
    final m = F1023HodgepodgeMachineSpiral();
    expect(m.id, 'f1023_hodgepodge_machine_spiral');
    expect(m.shader, 'shaders/f1023_hodgepodge_machine_spiral_gpu.frag');
  });

  test('F1023HodgepodgeMachineSpiral presets are well-formed', () {
    final m = F1023HodgepodgeMachineSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1023HodgepodgeMachineSpiral metadata is consistent', () {
    final m = F1023HodgepodgeMachineSpiral();
    expect(m.metadata.id, m.id);
  });
}
