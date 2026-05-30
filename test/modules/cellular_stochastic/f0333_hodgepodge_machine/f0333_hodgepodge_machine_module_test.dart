// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0333_hodgepodge_machine/f0333_hodgepodge_machine_module.dart';

void main() {
  test('F0333HodgepodgeMachine instantiates', () {
    final m = F0333HodgepodgeMachine();
    expect(m.id, 'f0333_hodgepodge_machine');
    expect(m.shader, 'shaders/f0333_hodgepodge_machine_gpu.frag');
  });

  test('F0333HodgepodgeMachine presets are well-formed', () {
    final m = F0333HodgepodgeMachine();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0333HodgepodgeMachine metadata is consistent', () {
    final m = F0333HodgepodgeMachine();
    expect(m.metadata.id, m.id);
  });
}
