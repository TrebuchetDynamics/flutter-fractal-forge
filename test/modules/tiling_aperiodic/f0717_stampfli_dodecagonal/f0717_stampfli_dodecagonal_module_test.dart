// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0717_stampfli_dodecagonal/f0717_stampfli_dodecagonal_module.dart';

void main() {
  test('F0717StampfliDodecagonal instantiates', () {
    final m = F0717StampfliDodecagonal();
    expect(m.id, 'f0717_stampfli_dodecagonal');
    expect(m.shader, 'shaders/f0717_stampfli_dodecagonal_gpu.frag');
  });

  test('F0717StampfliDodecagonal presets are well-formed', () {
    final m = F0717StampfliDodecagonal();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0717StampfliDodecagonal metadata is consistent', () {
    final m = F0717StampfliDodecagonal();
    expect(m.metadata.id, m.id);
  });
}
