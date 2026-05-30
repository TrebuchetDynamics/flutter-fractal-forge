// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1027_fhp_lattice_gas/f1027_fhp_lattice_gas_module.dart';

void main() {
  test('F1027FhpLatticeGas instantiates', () {
    final m = F1027FhpLatticeGas();
    expect(m.id, 'f1027_fhp_lattice_gas');
    expect(m.shader, 'shaders/f1027_fhp_lattice_gas_gpu.frag');
  });

  test('F1027FhpLatticeGas presets are well-formed', () {
    final m = F1027FhpLatticeGas();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1027FhpLatticeGas metadata is consistent', () {
    final m = F1027FhpLatticeGas();
    expect(m.metadata.id, m.id);
  });
}
