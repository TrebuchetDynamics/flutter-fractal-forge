// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0986_gnarl_b1_s1/f0986_gnarl_b1_s1_module.dart';

void main() {
  test('F0986GnarlB1S1 instantiates', () {
    final m = F0986GnarlB1S1();
    expect(m.id, 'f0986_gnarl_b1_s1');
    expect(m.shader, 'shaders/f0986_gnarl_b1_s1_gpu.frag');
  });

  test('F0986GnarlB1S1 presets are well-formed', () {
    final m = F0986GnarlB1S1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0986GnarlB1S1 metadata is consistent', () {
    final m = F0986GnarlB1S1();
    expect(m.metadata.id, m.id);
  });
}
