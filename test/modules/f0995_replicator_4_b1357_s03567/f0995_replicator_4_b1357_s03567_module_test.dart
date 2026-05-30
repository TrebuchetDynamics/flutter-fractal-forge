// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0995_replicator_4_b1357_s03567/f0995_replicator_4_b1357_s03567_module.dart';

void main() {
  test('F0995Replicator4B1357S03567 instantiates', () {
    final m = F0995Replicator4B1357S03567();
    expect(m.id, 'f0995_replicator_4_b1357_s03567');
    expect(m.shader, 'shaders/f0995_replicator_4_b1357_s03567_gpu.frag');
  });

  test('F0995Replicator4B1357S03567 presets are well-formed', () {
    final m = F0995Replicator4B1357S03567();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0995Replicator4B1357S03567 metadata is consistent', () {
    final m = F0995Replicator4B1357S03567();
    expect(m.metadata.id, m.id);
  });
}
