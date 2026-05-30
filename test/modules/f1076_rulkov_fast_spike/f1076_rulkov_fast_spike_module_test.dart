// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1076_rulkov_fast_spike/f1076_rulkov_fast_spike_module.dart';

void main() {
  test('F1076RulkovFastSpike instantiates', () {
    final m = F1076RulkovFastSpike();
    expect(m.id, 'f1076_rulkov_fast_spike');
    expect(m.shader, 'shaders/f1076_rulkov_fast_spike_gpu.frag');
  });

  test('F1076RulkovFastSpike presets are well-formed', () {
    final m = F1076RulkovFastSpike();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1076RulkovFastSpike metadata is consistent', () {
    final m = F1076RulkovFastSpike();
    expect(m.metadata.id, m.id);
  });
}
