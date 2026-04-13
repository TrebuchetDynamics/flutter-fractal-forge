// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0268_sierpinski_heptagon_ifs/f0268_sierpinski_heptagon_ifs_module.dart';

void main() {
  test('F0268SierpinskiHeptagonIfs instantiates', () {
    final m = F0268SierpinskiHeptagonIfs();
    expect(m.id, 'f0268_sierpinski_heptagon_ifs');
    expect(m.shader, 'shaders/f0268_sierpinski_heptagon_ifs_gpu.frag');
  });

  test('F0268SierpinskiHeptagonIfs presets are well-formed', () {
    final m = F0268SierpinskiHeptagonIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0268SierpinskiHeptagonIfs metadata is consistent', () {
    final m = F0268SierpinskiHeptagonIfs();
    expect(m.metadata.id, m.id);
  });
}
