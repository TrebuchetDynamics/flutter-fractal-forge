// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0032_sprott_s/f0032_sprott_s_module.dart';

void main() {
  test('F0032SprottS instantiates', () {
    final m = F0032SprottS();
    expect(m.id, 'f0032_sprott_s');
    expect(m.shader, 'shaders/f0032_sprott_s_gpu.frag');
  });

  test('F0032SprottS presets are well-formed', () {
    final m = F0032SprottS();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0032SprottS metadata is consistent', () {
    final m = F0032SprottS();
    expect(m.metadata.id, m.id);
  });
}
