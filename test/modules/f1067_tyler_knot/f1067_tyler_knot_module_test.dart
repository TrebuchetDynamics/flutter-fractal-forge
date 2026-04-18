// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1067_tyler_knot/f1067_tyler_knot_module.dart';

void main() {
  test('F1067TylerKnot instantiates', () {
    final m = F1067TylerKnot();
    expect(m.id, 'f1067_tyler_knot');
    expect(m.shader, 'shaders/f1067_tyler_knot_gpu.frag');
  });

  test('F1067TylerKnot presets are well-formed', () {
    final m = F1067TylerKnot();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1067TylerKnot metadata is consistent', () {
    final m = F1067TylerKnot();
    expect(m.metadata.id, m.id);
  });
}
