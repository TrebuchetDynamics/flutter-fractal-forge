// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0586_amazing_box_negative/f0586_amazing_box_negative_module.dart';

void main() {
  test('F0586AmazingBoxNegative instantiates', () {
    final m = F0586AmazingBoxNegative();
    expect(m.id, 'f0586_amazing_box_negative');
    expect(m.shader, 'shaders/f0586_amazing_box_negative_gpu.frag');
  });

  test('F0586AmazingBoxNegative presets are well-formed', () {
    final m = F0586AmazingBoxNegative();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0586AmazingBoxNegative metadata is consistent', () {
    final m = F0586AmazingBoxNegative();
    expect(m.metadata.id, m.id);
  });
}
