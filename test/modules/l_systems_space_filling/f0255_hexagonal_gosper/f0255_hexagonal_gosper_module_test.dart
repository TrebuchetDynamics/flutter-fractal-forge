// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0255_hexagonal_gosper/f0255_hexagonal_gosper_module.dart';

void main() {
  test('F0255HexagonalGosper instantiates', () {
    final m = F0255HexagonalGosper();
    expect(m.id, 'f0255_hexagonal_gosper');
    expect(m.shader, 'shaders/f0255_hexagonal_gosper_gpu.frag');
  });

  test('F0255HexagonalGosper presets are well-formed', () {
    final m = F0255HexagonalGosper();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0255HexagonalGosper metadata is consistent', () {
    final m = F0255HexagonalGosper();
    expect(m.metadata.id, m.id);
  });
}
