// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0063_moore_spiegel/f0063_moore_spiegel_module.dart';

void main() {
  test('F0063MooreSpiegel instantiates', () {
    final m = F0063MooreSpiegel();
    expect(m.id, 'f0063_moore_spiegel');
    expect(m.shader, 'shaders/f0063_moore_spiegel_gpu.frag');
  });

  test('F0063MooreSpiegel presets are well-formed', () {
    final m = F0063MooreSpiegel();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0063MooreSpiegel metadata is consistent', () {
    final m = F0063MooreSpiegel();
    expect(m.metadata.id, m.id);
  });
}
