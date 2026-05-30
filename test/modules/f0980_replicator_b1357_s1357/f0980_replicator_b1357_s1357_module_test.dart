// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0980_replicator_b1357_s1357/f0980_replicator_b1357_s1357_module.dart';

void main() {
  test('F0980ReplicatorB1357S1357 instantiates', () {
    final m = F0980ReplicatorB1357S1357();
    expect(m.id, 'f0980_replicator_b1357_s1357');
    expect(m.shader, 'shaders/f0980_replicator_b1357_s1357_gpu.frag');
  });

  test('F0980ReplicatorB1357S1357 presets are well-formed', () {
    final m = F0980ReplicatorB1357S1357();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0980ReplicatorB1357S1357 metadata is consistent', () {
    final m = F0980ReplicatorB1357S1357();
    expect(m.metadata.id, m.id);
  });
}
