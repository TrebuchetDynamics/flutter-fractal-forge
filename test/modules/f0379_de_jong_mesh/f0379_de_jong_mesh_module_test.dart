// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0379_de_jong_mesh/f0379_de_jong_mesh_module.dart';

void main() {
  test('F0379DeJongMesh instantiates', () {
    final m = F0379DeJongMesh();
    expect(m.id, 'f0379_de_jong_mesh');
    expect(m.shader, 'shaders/f0379_de_jong_mesh_gpu.frag');
  });

  test('F0379DeJongMesh presets are well-formed', () {
    final m = F0379DeJongMesh();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0379DeJongMesh metadata is consistent', () {
    final m = F0379DeJongMesh();
    expect(m.metadata.id, m.id);
  });
}
