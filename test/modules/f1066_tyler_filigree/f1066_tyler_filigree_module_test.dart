// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1066_tyler_filigree/f1066_tyler_filigree_module.dart';

void main() {
  test('F1066TylerFiligree instantiates', () {
    final m = F1066TylerFiligree();
    expect(m.id, 'f1066_tyler_filigree');
    expect(m.shader, 'shaders/f1066_tyler_filigree_gpu.frag');
  });

  test('F1066TylerFiligree presets are well-formed', () {
    final m = F1066TylerFiligree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1066TylerFiligree metadata is consistent', () {
    final m = F1066TylerFiligree();
    expect(m.metadata.id, m.id);
  });
}
