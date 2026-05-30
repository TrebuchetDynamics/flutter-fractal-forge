// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1097_lozi_edge/f1097_lozi_edge_module.dart';

void main() {
  test('F1097LoziEdge instantiates', () {
    final m = F1097LoziEdge();
    expect(m.id, 'f1097_lozi_edge');
    expect(m.shader, 'shaders/f1097_lozi_edge_gpu.frag');
  });

  test('F1097LoziEdge presets are well-formed', () {
    final m = F1097LoziEdge();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1097LoziEdge metadata is consistent', () {
    final m = F1097LoziEdge();
    expect(m.metadata.id, m.id);
  });
}
