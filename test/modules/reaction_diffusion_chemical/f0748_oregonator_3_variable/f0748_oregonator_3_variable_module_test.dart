// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0748_oregonator_3_variable/f0748_oregonator_3_variable_module.dart';

void main() {
  test('F0748Oregonator3Variable instantiates', () {
    final m = F0748Oregonator3Variable();
    expect(m.id, 'f0748_oregonator_3_variable');
    expect(m.shader, 'shaders/f0748_oregonator_3_variable_gpu.frag');
  });

  test('F0748Oregonator3Variable presets are well-formed', () {
    final m = F0748Oregonator3Variable();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0748Oregonator3Variable metadata is consistent', () {
    final m = F0748Oregonator3Variable();
    expect(m.metadata.id, m.id);
  });
}
