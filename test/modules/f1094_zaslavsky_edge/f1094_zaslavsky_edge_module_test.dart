// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1094_zaslavsky_edge/f1094_zaslavsky_edge_module.dart';

void main() {
  test('F1094ZaslavskyEdge instantiates', () {
    final m = F1094ZaslavskyEdge();
    expect(m.id, 'f1094_zaslavsky_edge');
    expect(m.shader, 'shaders/f1094_zaslavsky_edge_gpu.frag');
  });

  test('F1094ZaslavskyEdge presets are well-formed', () {
    final m = F1094ZaslavskyEdge();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1094ZaslavskyEdge metadata is consistent', () {
    final m = F1094ZaslavskyEdge();
    expect(m.metadata.id, m.id);
  });
}
