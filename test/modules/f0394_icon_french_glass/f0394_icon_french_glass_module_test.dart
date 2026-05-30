// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0394_icon_french_glass/f0394_icon_french_glass_module.dart';

void main() {
  test('F0394IconFrenchGlass instantiates', () {
    final m = F0394IconFrenchGlass();
    expect(m.id, 'f0394_icon_french_glass');
    expect(m.shader, 'shaders/f0394_icon_french_glass_gpu.frag');
  });

  test('F0394IconFrenchGlass presets are well-formed', () {
    final m = F0394IconFrenchGlass();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0394IconFrenchGlass metadata is consistent', () {
    final m = F0394IconFrenchGlass();
    expect(m.metadata.id, m.id);
  });
}
