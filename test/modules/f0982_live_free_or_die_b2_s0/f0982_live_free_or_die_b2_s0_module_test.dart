// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f0982_live_free_or_die_b2_s0/f0982_live_free_or_die_b2_s0_module.dart';

void main() {
  test('F0982LiveFreeOrDieB2S0 instantiates', () {
    final m = F0982LiveFreeOrDieB2S0();
    expect(m.id, 'f0982_live_free_or_die_b2_s0');
    expect(m.shader, 'shaders/f0982_live_free_or_die_b2_s0_gpu.frag');
  });

  test('F0982LiveFreeOrDieB2S0 presets are well-formed', () {
    final m = F0982LiveFreeOrDieB2S0();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0982LiveFreeOrDieB2S0 metadata is consistent', () {
    final m = F0982LiveFreeOrDieB2S0();
    expect(m.metadata.id, m.id);
  });
}
