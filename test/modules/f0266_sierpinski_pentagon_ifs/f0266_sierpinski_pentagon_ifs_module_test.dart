// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0266_sierpinski_pentagon_ifs/f0266_sierpinski_pentagon_ifs_module.dart';

void main() {
  test('F0266SierpinskiPentagonIfs instantiates', () {
    final m = F0266SierpinskiPentagonIfs();
    expect(m.id, 'f0266_sierpinski_pentagon_ifs');
    expect(m.shader, 'shaders/f0266_sierpinski_pentagon_ifs_gpu.frag');
  });

  test('F0266SierpinskiPentagonIfs presets are well-formed', () {
    final m = F0266SierpinskiPentagonIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0266SierpinskiPentagonIfs metadata is consistent', () {
    final m = F0266SierpinskiPentagonIfs();
    expect(m.metadata.id, m.id);
  });
}
