// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0267_sierpinski_hexagon_ifs/f0267_sierpinski_hexagon_ifs_module.dart';

void main() {
  test('F0267SierpinskiHexagonIfs instantiates', () {
    final m = F0267SierpinskiHexagonIfs();
    expect(m.id, 'f0267_sierpinski_hexagon_ifs');
    expect(m.shader, 'shaders/f0267_sierpinski_hexagon_ifs_gpu.frag');
  });

  test('F0267SierpinskiHexagonIfs presets are well-formed', () {
    final m = F0267SierpinskiHexagonIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0267SierpinskiHexagonIfs metadata is consistent', () {
    final m = F0267SierpinskiHexagonIfs();
    expect(m.metadata.id, m.id);
  });
}
