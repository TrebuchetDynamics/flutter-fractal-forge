// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0838_gosper_island/f0838_gosper_island_module.dart';

void main() {
  test('F0838GosperIsland instantiates', () {
    final m = F0838GosperIsland();
    expect(m.id, 'f0838_gosper_island');
    expect(m.shader, 'shaders/f0838_gosper_island_gpu.frag');
  });

  test('F0838GosperIsland presets are well-formed', () {
    final m = F0838GosperIsland();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0838GosperIsland metadata is consistent', () {
    final m = F0838GosperIsland();
    expect(m.metadata.id, m.id);
  });
}
