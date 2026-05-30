// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0402_icon_clam_d5/f0402_icon_clam_d5_module.dart';

void main() {
  test('F0402IconClamD5 instantiates', () {
    final m = F0402IconClamD5();
    expect(m.id, 'f0402_icon_clam_d5');
    expect(m.shader, 'shaders/f0402_icon_clam_d5_gpu.frag');
  });

  test('F0402IconClamD5 presets are well-formed', () {
    final m = F0402IconClamD5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0402IconClamD5 metadata is consistent', () {
    final m = F0402IconClamD5();
    expect(m.metadata.id, m.id);
  });
}
