// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0029_sprott_p/f0029_sprott_p_module.dart';

void main() {
  test('F0029SprottP instantiates', () {
    final m = F0029SprottP();
    expect(m.id, 'f0029_sprott_p');
    expect(m.shader, 'shaders/f0029_sprott_p_gpu.frag');
  });

  test('F0029SprottP presets are well-formed', () {
    final m = F0029SprottP();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0029SprottP metadata is consistent', () {
    final m = F0029SprottP();
    expect(m.metadata.id, m.id);
  });
}
