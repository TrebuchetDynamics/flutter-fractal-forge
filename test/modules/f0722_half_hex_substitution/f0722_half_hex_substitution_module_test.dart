// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0722_half_hex_substitution/f0722_half_hex_substitution_module.dart';

void main() {
  test('F0722HalfHexSubstitution instantiates', () {
    final m = F0722HalfHexSubstitution();
    expect(m.id, 'f0722_half_hex_substitution');
    expect(m.shader, 'shaders/f0722_half_hex_substitution_gpu.frag');
  });

  test('F0722HalfHexSubstitution presets are well-formed', () {
    final m = F0722HalfHexSubstitution();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0722HalfHexSubstitution metadata is consistent', () {
    final m = F0722HalfHexSubstitution();
    expect(m.metadata.id, m.id);
  });
}
