// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0382_de_jong_cascade/f0382_de_jong_cascade_module.dart';

void main() {
  test('F0382DeJongCascade instantiates', () {
    final m = F0382DeJongCascade();
    expect(m.id, 'f0382_de_jong_cascade');
    expect(m.shader, 'shaders/f0382_de_jong_cascade_gpu.frag');
  });

  test('F0382DeJongCascade presets are well-formed', () {
    final m = F0382DeJongCascade();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0382DeJongCascade metadata is consistent', () {
    final m = F0382DeJongCascade();
    expect(m.metadata.id, m.id);
  });
}
