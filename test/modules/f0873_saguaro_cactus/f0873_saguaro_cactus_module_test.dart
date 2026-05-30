// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0873_saguaro_cactus/f0873_saguaro_cactus_module.dart';

void main() {
  test('F0873SaguaroCactus instantiates', () {
    final m = F0873SaguaroCactus();
    expect(m.id, 'f0873_saguaro_cactus');
    expect(m.shader, 'shaders/f0873_saguaro_cactus_gpu.frag');
  });

  test('F0873SaguaroCactus presets are well-formed', () {
    final m = F0873SaguaroCactus();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0873SaguaroCactus metadata is consistent', () {
    final m = F0873SaguaroCactus();
    expect(m.metadata.id, m.id);
  });
}
