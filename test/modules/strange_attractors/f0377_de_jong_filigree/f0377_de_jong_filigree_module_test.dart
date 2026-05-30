// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0377_de_jong_filigree/f0377_de_jong_filigree_module.dart';

void main() {
  test('F0377DeJongFiligree instantiates', () {
    final m = F0377DeJongFiligree();
    expect(m.id, 'f0377_de_jong_filigree');
    expect(m.shader, 'shaders/f0377_de_jong_filigree_gpu.frag');
  });

  test('F0377DeJongFiligree presets are well-formed', () {
    final m = F0377DeJongFiligree();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0377DeJongFiligree metadata is consistent', () {
    final m = F0377DeJongFiligree();
    expect(m.metadata.id, m.id);
  });
}
