// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0405_icon_pentagon_d5/f0405_icon_pentagon_d5_module.dart';

void main() {
  test('F0405IconPentagonD5 instantiates', () {
    final m = F0405IconPentagonD5();
    expect(m.id, 'f0405_icon_pentagon_d5');
    expect(m.shader, 'shaders/f0405_icon_pentagon_d5_gpu.frag');
  });

  test('F0405IconPentagonD5 presets are well-formed', () {
    final m = F0405IconPentagonD5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0405IconPentagonD5 metadata is consistent', () {
    final m = F0405IconPentagonD5();
    expect(m.metadata.id, m.id);
  });
}
