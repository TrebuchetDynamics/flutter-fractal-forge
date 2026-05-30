// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0022_sprott_i/f0022_sprott_i_module.dart';

void main() {
  test('F0022SprottI instantiates', () {
    final m = F0022SprottI();
    expect(m.id, 'f0022_sprott_i');
    expect(m.shader, 'shaders/f0022_sprott_i_gpu.frag');
  });

  test('F0022SprottI presets are well-formed', () {
    final m = F0022SprottI();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0022SprottI metadata is consistent', () {
    final m = F0022SprottI();
    expect(m.metadata.id, m.id);
  });
}
