// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0129_magnet_1/f0129_magnet_1_module.dart';

void main() {
  test('F0129Magnet1 instantiates', () {
    final m = F0129Magnet1();
    expect(m.id, 'f0129_magnet_1');
    expect(m.shader, 'shaders/f0129_magnet_1_gpu.frag');
  });

  test('F0129Magnet1 presets are well-formed', () {
    final m = F0129Magnet1();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0129Magnet1 metadata is consistent', () {
    final m = F0129Magnet1();
    expect(m.metadata.id, m.id);
  });
}
