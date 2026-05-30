// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1007_highflock_b36_s12/f1007_highflock_b36_s12_module.dart';

void main() {
  test('F1007HighflockB36S12 instantiates', () {
    final m = F1007HighflockB36S12();
    expect(m.id, 'f1007_highflock_b36_s12');
    expect(m.shader, 'shaders/f1007_highflock_b36_s12_gpu.frag');
  });

  test('F1007HighflockB36S12 presets are well-formed', () {
    final m = F1007HighflockB36S12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1007HighflockB36S12 metadata is consistent', () {
    final m = F1007HighflockB36S12();
    expect(m.metadata.id, m.id);
  });
}
