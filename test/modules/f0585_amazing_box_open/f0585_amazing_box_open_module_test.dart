// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0585_amazing_box_open/f0585_amazing_box_open_module.dart';

void main() {
  test('F0585AmazingBoxOpen instantiates', () {
    final m = F0585AmazingBoxOpen();
    expect(m.id, 'f0585_amazing_box_open');
    expect(m.shader, 'shaders/f0585_amazing_box_open_gpu.frag');
  });

  test('F0585AmazingBoxOpen presets are well-formed', () {
    final m = F0585AmazingBoxOpen();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0585AmazingBoxOpen metadata is consistent', () {
    final m = F0585AmazingBoxOpen();
    expect(m.metadata.id, m.id);
  });
}
