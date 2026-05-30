// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0772_thue_morse_sequence/f0772_thue_morse_sequence_module.dart';

void main() {
  test('F0772ThueMorseSequence instantiates', () {
    final m = F0772ThueMorseSequence();
    expect(m.id, 'f0772_thue_morse_sequence');
    expect(m.shader, 'shaders/f0772_thue_morse_sequence_gpu.frag');
  });

  test('F0772ThueMorseSequence presets are well-formed', () {
    final m = F0772ThueMorseSequence();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0772ThueMorseSequence metadata is consistent', () {
    final m = F0772ThueMorseSequence();
    expect(m.metadata.id, m.id);
  });
}
