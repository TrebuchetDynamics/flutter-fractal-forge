// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0392_icon_five_fold/f0392_icon_five_fold_module.dart';

void main() {
  test('F0392IconFiveFold instantiates', () {
    final m = F0392IconFiveFold();
    expect(m.id, 'f0392_icon_five_fold');
    expect(m.shader, 'shaders/f0392_icon_five_fold_gpu.frag');
  });

  test('F0392IconFiveFold presets are well-formed', () {
    final m = F0392IconFiveFold();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0392IconFiveFold metadata is consistent', () {
    final m = F0392IconFiveFold();
    expect(m.metadata.id, m.id);
  });
}
