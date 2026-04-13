// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0373_de_jong_crescent/f0373_de_jong_crescent_module.dart';

void main() {
  test('F0373DeJongCrescent instantiates', () {
    final m = F0373DeJongCrescent();
    expect(m.id, 'f0373_de_jong_crescent');
    expect(m.shader, 'shaders/f0373_de_jong_crescent_gpu.frag');
  });

  test('F0373DeJongCrescent presets are well-formed', () {
    final m = F0373DeJongCrescent();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0373DeJongCrescent metadata is consistent', () {
    final m = F0373DeJongCrescent();
    expect(m.metadata.id, m.id);
  });
}
