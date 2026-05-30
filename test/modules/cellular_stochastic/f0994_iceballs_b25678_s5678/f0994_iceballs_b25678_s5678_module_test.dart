// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0994_iceballs_b25678_s5678/f0994_iceballs_b25678_s5678_module.dart';

void main() {
  test('F0994IceballsB25678S5678 instantiates', () {
    final m = F0994IceballsB25678S5678();
    expect(m.id, 'f0994_iceballs_b25678_s5678');
    expect(m.shader, 'shaders/f0994_iceballs_b25678_s5678_gpu.frag');
  });

  test('F0994IceballsB25678S5678 presets are well-formed', () {
    final m = F0994IceballsB25678S5678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0994IceballsB25678S5678 metadata is consistent', () {
    final m = F0994IceballsB25678S5678();
    expect(m.metadata.id, m.id);
  });
}
