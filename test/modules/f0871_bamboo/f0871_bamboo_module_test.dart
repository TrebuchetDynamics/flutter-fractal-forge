// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0871_bamboo/f0871_bamboo_module.dart';

void main() {
  test('F0871Bamboo instantiates', () {
    final m = F0871Bamboo();
    expect(m.id, 'f0871_bamboo');
    expect(m.shader, 'shaders/f0871_bamboo_gpu.frag');
  });

  test('F0871Bamboo presets are well-formed', () {
    final m = F0871Bamboo();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0871Bamboo metadata is consistent', () {
    final m = F0871Bamboo();
    expect(m.metadata.id, m.id);
  });
}
