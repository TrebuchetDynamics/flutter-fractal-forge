// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1026_margolus_block_ca_hpp_gas/f1026_margolus_block_ca_hpp_gas_module.dart';

void main() {
  test('F1026MargolusBlockCaHppGas instantiates', () {
    final m = F1026MargolusBlockCaHppGas();
    expect(m.id, 'f1026_margolus_block_ca_hpp_gas');
    expect(m.shader, 'shaders/f1026_margolus_block_ca_hpp_gas_gpu.frag');
  });

  test('F1026MargolusBlockCaHppGas presets are well-formed', () {
    final m = F1026MargolusBlockCaHppGas();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1026MargolusBlockCaHppGas metadata is consistent', () {
    final m = F1026MargolusBlockCaHppGas();
    expect(m.metadata.id, m.id);
  });
}
