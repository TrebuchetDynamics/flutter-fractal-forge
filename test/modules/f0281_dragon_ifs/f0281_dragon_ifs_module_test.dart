// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f0281_dragon_ifs/f0281_dragon_ifs_module.dart';

void main() {
  test('F0281DragonIfs instantiates', () {
    final m = F0281DragonIfs();
    expect(m.id, 'f0281_dragon_ifs');
    expect(m.shader, 'shaders/f0281_dragon_ifs_gpu.frag');
  });

  test('F0281DragonIfs presets are well-formed', () {
    final m = F0281DragonIfs();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0281DragonIfs metadata is consistent', () {
    final m = F0281DragonIfs();
    expect(m.metadata.id, m.id);
  });
}
