// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0708_socolar_taylor_hexagonal_monotile/f0708_socolar_taylor_hexagonal_monotile_module.dart';

void main() {
  test('F0708SocolarTaylorHexagonalMonotile instantiates', () {
    final m = F0708SocolarTaylorHexagonalMonotile();
    expect(m.id, 'f0708_socolar_taylor_hexagonal_monotile');
    expect(
        m.shader, 'shaders/f0708_socolar_taylor_hexagonal_monotile_gpu.frag');
  });

  test('F0708SocolarTaylorHexagonalMonotile presets are well-formed', () {
    final m = F0708SocolarTaylorHexagonalMonotile();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0708SocolarTaylorHexagonalMonotile metadata is consistent', () {
    final m = F0708SocolarTaylorHexagonalMonotile();
    expect(m.metadata.id, m.id);
  });
}
