// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0721_paul_bourke_hexagonal_random_tiling/f0721_paul_bourke_hexagonal_random_tiling_module.dart';

void main() {
  test('F0721PaulBourkeHexagonalRandomTiling instantiates', () {
    final m = F0721PaulBourkeHexagonalRandomTiling();
    expect(m.id, 'f0721_paul_bourke_hexagonal_random_tiling');
    expect(
        m.shader, 'shaders/f0721_paul_bourke_hexagonal_random_tiling_gpu.frag');
  });

  test('F0721PaulBourkeHexagonalRandomTiling presets are well-formed', () {
    final m = F0721PaulBourkeHexagonalRandomTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0721PaulBourkeHexagonalRandomTiling metadata is consistent', () {
    final m = F0721PaulBourkeHexagonalRandomTiling();
    expect(m.metadata.id, m.id);
  });
}
