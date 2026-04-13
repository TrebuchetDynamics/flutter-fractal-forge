// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0384_de_jong_web/f0384_de_jong_web_module.dart';

void main() {
  test('F0384DeJongWeb instantiates', () {
    final m = F0384DeJongWeb();
    expect(m.id, 'f0384_de_jong_web');
    expect(m.shader, 'shaders/f0384_de_jong_web_gpu.frag');
  });

  test('F0384DeJongWeb presets are well-formed', () {
    final m = F0384DeJongWeb();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0384DeJongWeb metadata is consistent', () {
    final m = F0384DeJongWeb();
    expect(m.metadata.id, m.id);
  });
}
