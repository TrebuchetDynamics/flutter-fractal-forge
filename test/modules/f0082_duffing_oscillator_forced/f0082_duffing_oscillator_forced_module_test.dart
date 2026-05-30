// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0082_duffing_oscillator_forced/f0082_duffing_oscillator_forced_module.dart';

void main() {
  test('F0082DuffingOscillatorForced instantiates', () {
    final m = F0082DuffingOscillatorForced();
    expect(m.id, 'f0082_duffing_oscillator_forced');
    expect(m.shader, 'shaders/f0082_duffing_oscillator_forced_gpu.frag');
  });

  test('F0082DuffingOscillatorForced presets are well-formed', () {
    final m = F0082DuffingOscillatorForced();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0082DuffingOscillatorForced metadata is consistent', () {
    final m = F0082DuffingOscillatorForced();
    expect(m.metadata.id, m.id);
  });
}
