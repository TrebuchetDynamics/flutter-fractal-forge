// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0091_multibrot_z_16/f0091_multibrot_z_16_module.dart';

void main() {
  test('F0091MultibrotZ16 instantiates', () {
    final m = F0091MultibrotZ16();
    expect(m.id, 'f0091_multibrot_z_16');
    expect(m.shader, 'shaders/f0091_multibrot_z_16_gpu.frag');
  });

  test('F0091MultibrotZ16 presets are well-formed', () {
    final m = F0091MultibrotZ16();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0091MultibrotZ16 metadata is consistent', () {
    final m = F0091MultibrotZ16();
    expect(m.metadata.id, m.id);
  });
}
