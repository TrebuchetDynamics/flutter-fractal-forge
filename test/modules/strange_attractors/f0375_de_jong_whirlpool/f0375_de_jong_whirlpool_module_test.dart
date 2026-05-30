// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0375_de_jong_whirlpool/f0375_de_jong_whirlpool_module.dart';

void main() {
  test('F0375DeJongWhirlpool instantiates', () {
    final m = F0375DeJongWhirlpool();
    expect(m.id, 'f0375_de_jong_whirlpool');
    expect(m.shader, 'shaders/f0375_de_jong_whirlpool_gpu.frag');
  });

  test('F0375DeJongWhirlpool presets are well-formed', () {
    final m = F0375DeJongWhirlpool();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0375DeJongWhirlpool metadata is consistent', () {
    final m = F0375DeJongWhirlpool();
    expect(m.metadata.id, m.id);
  });
}
