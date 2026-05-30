// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0401_icon_rosette_d4/f0401_icon_rosette_d4_module.dart';

void main() {
  test('F0401IconRosetteD4 instantiates', () {
    final m = F0401IconRosetteD4();
    expect(m.id, 'f0401_icon_rosette_d4');
    expect(m.shader, 'shaders/f0401_icon_rosette_d4_gpu.frag');
  });

  test('F0401IconRosetteD4 presets are well-formed', () {
    final m = F0401IconRosetteD4();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0401IconRosetteD4 metadata is consistent', () {
    final m = F0401IconRosetteD4();
    expect(m.metadata.id, m.id);
  });
}
