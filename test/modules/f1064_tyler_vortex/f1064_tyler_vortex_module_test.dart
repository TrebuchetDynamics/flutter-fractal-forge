// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1064_tyler_vortex/f1064_tyler_vortex_module.dart';

void main() {
  test('F1064TylerVortex instantiates', () {
    final m = F1064TylerVortex();
    expect(m.id, 'f1064_tyler_vortex');
    expect(m.shader, 'shaders/f1064_tyler_vortex_gpu.frag');
  });

  test('F1064TylerVortex presets are well-formed', () {
    final m = F1064TylerVortex();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1064TylerVortex metadata is consistent', () {
    final m = F1064TylerVortex();
    expect(m.metadata.id, m.id);
  });
}
