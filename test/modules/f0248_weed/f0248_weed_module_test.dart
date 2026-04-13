// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0248_weed/f0248_weed_module.dart';

void main() {
  test('F0248Weed instantiates', () {
    final m = F0248Weed();
    expect(m.id, 'f0248_weed');
    expect(m.shader, 'shaders/f0248_weed_gpu.frag');
  });

  test('F0248Weed presets are well-formed', () {
    final m = F0248Weed();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0248Weed metadata is consistent', () {
    final m = F0248Weed();
    expect(m.metadata.id, m.id);
  });
}
