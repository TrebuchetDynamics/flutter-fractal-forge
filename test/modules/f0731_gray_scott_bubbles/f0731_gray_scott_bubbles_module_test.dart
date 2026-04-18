// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0731_gray_scott_bubbles/f0731_gray_scott_bubbles_module.dart';

void main() {
  test('F0731GrayScottBubbles instantiates', () {
    final m = F0731GrayScottBubbles();
    expect(m.id, 'f0731_gray_scott_bubbles');
    expect(m.shader, 'shaders/f0731_gray_scott_bubbles_gpu.frag');
  });

  test('F0731GrayScottBubbles presets are well-formed', () {
    final m = F0731GrayScottBubbles();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0731GrayScottBubbles metadata is consistent', () {
    final m = F0731GrayScottBubbles();
    expect(m.metadata.id, m.id);
  });
}
