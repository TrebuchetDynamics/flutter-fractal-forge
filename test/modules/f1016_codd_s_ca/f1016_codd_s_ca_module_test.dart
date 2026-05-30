// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1016_codd_s_ca/f1016_codd_s_ca_module.dart';

void main() {
  test('F1016CoddSCa instantiates', () {
    final m = F1016CoddSCa();
    expect(m.id, 'f1016_codd_s_ca');
    expect(m.shader, 'shaders/f1016_codd_s_ca_gpu.frag');
  });

  test('F1016CoddSCa presets are well-formed', () {
    final m = F1016CoddSCa();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1016CoddSCa metadata is consistent', () {
    final m = F1016CoddSCa();
    expect(m.metadata.id, m.id);
  });
}
