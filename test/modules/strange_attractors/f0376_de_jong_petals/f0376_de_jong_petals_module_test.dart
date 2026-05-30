// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0376_de_jong_petals/f0376_de_jong_petals_module.dart';

void main() {
  test('F0376DeJongPetals instantiates', () {
    final m = F0376DeJongPetals();
    expect(m.id, 'f0376_de_jong_petals');
    expect(m.shader, 'shaders/f0376_de_jong_petals_gpu.frag');
  });

  test('F0376DeJongPetals presets are well-formed', () {
    final m = F0376DeJongPetals();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0376DeJongPetals metadata is consistent', () {
    final m = F0376DeJongPetals();
    expect(m.metadata.id, m.id);
  });
}
