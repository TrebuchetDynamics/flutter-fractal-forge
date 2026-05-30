// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1063_tyler_storm/f1063_tyler_storm_module.dart';

void main() {
  test('F1063TylerStorm instantiates', () {
    final m = F1063TylerStorm();
    expect(m.id, 'f1063_tyler_storm');
    expect(m.shader, 'shaders/f1063_tyler_storm_gpu.frag');
  });

  test('F1063TylerStorm presets are well-formed', () {
    final m = F1063TylerStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1063TylerStorm metadata is consistent', () {
    final m = F1063TylerStorm();
    expect(m.metadata.id, m.id);
  });
}
