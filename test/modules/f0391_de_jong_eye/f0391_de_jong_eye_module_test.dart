// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0391_de_jong_eye/f0391_de_jong_eye_module.dart';

void main() {
  test('F0391DeJongEye instantiates', () {
    final m = F0391DeJongEye();
    expect(m.id, 'f0391_de_jong_eye');
    expect(m.shader, 'shaders/f0391_de_jong_eye_gpu.frag');
  });

  test('F0391DeJongEye presets are well-formed', () {
    final m = F0391DeJongEye();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0391DeJongEye metadata is consistent', () {
    final m = F0391DeJongEye();
    expect(m.metadata.id, m.id);
  });
}
