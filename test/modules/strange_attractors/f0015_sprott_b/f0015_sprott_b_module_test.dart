// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0015_sprott_b/f0015_sprott_b_module.dart';

void main() {
  test('F0015SprottB instantiates', () {
    final m = F0015SprottB();
    expect(m.id, 'f0015_sprott_b');
    expect(m.shader, 'shaders/f0015_sprott_b_gpu.frag');
  });

  test('F0015SprottB presets are well-formed', () {
    final m = F0015SprottB();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0015SprottB metadata is consistent', () {
    final m = F0015SprottB();
    expect(m.metadata.id, m.id);
  });
}
