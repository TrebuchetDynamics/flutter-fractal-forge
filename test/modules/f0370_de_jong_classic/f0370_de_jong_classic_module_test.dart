// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0370_de_jong_classic/f0370_de_jong_classic_module.dart';

void main() {
  test('F0370DeJongClassic instantiates', () {
    final m = F0370DeJongClassic();
    expect(m.id, 'f0370_de_jong_classic');
    expect(m.shader, 'shaders/f0370_de_jong_classic_gpu.frag');
  });

  test('F0370DeJongClassic presets are well-formed', () {
    final m = F0370DeJongClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0370DeJongClassic metadata is consistent', () {
    final m = F0370DeJongClassic();
    expect(m.metadata.id, m.id);
  });
}
