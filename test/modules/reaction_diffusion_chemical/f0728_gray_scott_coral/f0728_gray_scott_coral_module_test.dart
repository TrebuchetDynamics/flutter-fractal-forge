// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0728_gray_scott_coral/f0728_gray_scott_coral_module.dart';

void main() {
  test('F0728GrayScottCoral instantiates', () {
    final m = F0728GrayScottCoral();
    expect(m.id, 'f0728_gray_scott_coral');
    expect(m.shader, 'shaders/f0728_gray_scott_coral_gpu.frag');
  });

  test('F0728GrayScottCoral presets are well-formed', () {
    final m = F0728GrayScottCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0728GrayScottCoral metadata is consistent', () {
    final m = F0728GrayScottCoral();
    expect(m.metadata.id, m.id);
  });
}
