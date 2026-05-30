// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0981_fredkin_s_replicator_b1357_s02468/f0981_fredkin_s_replicator_b1357_s02468_module.dart';

void main() {
  test('F0981FredkinSReplicatorB1357S02468 instantiates', () {
    final m = F0981FredkinSReplicatorB1357S02468();
    expect(m.id, 'f0981_fredkin_s_replicator_b1357_s02468');
    expect(
        m.shader, 'shaders/f0981_fredkin_s_replicator_b1357_s02468_gpu.frag');
  });

  test('F0981FredkinSReplicatorB1357S02468 presets are well-formed', () {
    final m = F0981FredkinSReplicatorB1357S02468();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0981FredkinSReplicatorB1357S02468 metadata is consistent', () {
    final m = F0981FredkinSReplicatorB1357S02468();
    expect(m.metadata.id, m.id);
  });
}
