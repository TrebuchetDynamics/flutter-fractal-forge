// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0130_magnet_2/f0130_magnet_2_module.dart';

void main() {
  test('F0130Magnet2 instantiates', () {
    final m = F0130Magnet2();
    expect(m.id, 'f0130_magnet_2');
    expect(m.shader, 'shaders/f0130_magnet_2_gpu.frag');
  });

  test('F0130Magnet2 presets are well-formed', () {
    final m = F0130Magnet2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0130Magnet2 metadata is consistent', () {
    final m = F0130Magnet2();
    expect(m.metadata.id, m.id);
  });
}
