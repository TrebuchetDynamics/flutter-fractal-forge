// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0400_icon_flag/f0400_icon_flag_module.dart';

void main() {
  test('F0400IconFlag instantiates', () {
    final m = F0400IconFlag();
    expect(m.id, 'f0400_icon_flag');
    expect(m.shader, 'shaders/f0400_icon_flag_gpu.frag');
  });

  test('F0400IconFlag presets are well-formed', () {
    final m = F0400IconFlag();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0400IconFlag metadata is consistent', () {
    final m = F0400IconFlag();
    expect(m.metadata.id, m.id);
  });
}
