// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1065_tyler_mesh/f1065_tyler_mesh_module.dart';

void main() {
  test('F1065TylerMesh instantiates', () {
    final m = F1065TylerMesh();
    expect(m.id, 'f1065_tyler_mesh');
    expect(m.shader, 'shaders/f1065_tyler_mesh_gpu.frag');
  });

  test('F1065TylerMesh presets are well-formed', () {
    final m = F1065TylerMesh();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1065TylerMesh metadata is consistent', () {
    final m = F1065TylerMesh();
    expect(m.metadata.id, m.id);
  });
}
