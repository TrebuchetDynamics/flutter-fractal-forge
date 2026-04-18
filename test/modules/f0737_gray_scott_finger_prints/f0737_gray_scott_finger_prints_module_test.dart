// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/reaction_diffusion_chemical/f0737_gray_scott_finger_prints/f0737_gray_scott_finger_prints_module.dart';

void main() {
  test('F0737GrayScottFingerPrints instantiates', () {
    final m = F0737GrayScottFingerPrints();
    expect(m.id, 'f0737_gray_scott_finger_prints');
    expect(m.shader, 'shaders/f0737_gray_scott_finger_prints_gpu.frag');
  });

  test('F0737GrayScottFingerPrints presets are well-formed', () {
    final m = F0737GrayScottFingerPrints();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0737GrayScottFingerPrints metadata is consistent', () {
    final m = F0737GrayScottFingerPrints();
    expect(m.metadata.id, m.id);
  });
}
