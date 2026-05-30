// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0269_sierpinski_octagon_ifs/f0269_sierpinski_octagon_ifs_module.dart';

void main() {
  test('F0269SierpinskiOctagonIfs instantiates', () {
    final m = F0269SierpinskiOctagonIfs();
    expect(m.id, 'f0269_sierpinski_octagon_ifs');
    expect(m.shader, 'shaders/f0269_sierpinski_octagon_ifs_gpu.frag');
  });

  test('F0269SierpinskiOctagonIfs presets are well-formed', () {
    final m = F0269SierpinskiOctagonIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0269SierpinskiOctagonIfs metadata is consistent', () {
    final m = F0269SierpinskiOctagonIfs();
    expect(m.metadata.id, m.id);
  });
}
