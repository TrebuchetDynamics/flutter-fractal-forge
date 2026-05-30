// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0385_de_jong_hurricane/f0385_de_jong_hurricane_module.dart';

void main() {
  test('F0385DeJongHurricane instantiates', () {
    final m = F0385DeJongHurricane();
    expect(m.id, 'f0385_de_jong_hurricane');
    expect(m.shader, 'shaders/f0385_de_jong_hurricane_gpu.frag');
  });

  test('F0385DeJongHurricane presets are well-formed', () {
    final m = F0385DeJongHurricane();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0385DeJongHurricane metadata is consistent', () {
    final m = F0385DeJongHurricane();
    expect(m.metadata.id, m.id);
  });
}
