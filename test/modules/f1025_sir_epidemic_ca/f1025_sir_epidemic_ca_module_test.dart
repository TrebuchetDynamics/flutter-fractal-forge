// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1025_sir_epidemic_ca/f1025_sir_epidemic_ca_module.dart';

void main() {
  test('F1025SirEpidemicCa instantiates', () {
    final m = F1025SirEpidemicCa();
    expect(m.id, 'f1025_sir_epidemic_ca');
    expect(m.shader, 'shaders/f1025_sir_epidemic_ca_gpu.frag');
  });

  test('F1025SirEpidemicCa presets are well-formed', () {
    final m = F1025SirEpidemicCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1025SirEpidemicCa metadata is consistent', () {
    final m = F1025SirEpidemicCa();
    expect(m.metadata.id, m.id);
  });
}
