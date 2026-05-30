// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0388_de_jong_butterfly/f0388_de_jong_butterfly_module.dart';

void main() {
  test('F0388DeJongButterfly instantiates', () {
    final m = F0388DeJongButterfly();
    expect(m.id, 'f0388_de_jong_butterfly');
    expect(m.shader, 'shaders/f0388_de_jong_butterfly_gpu.frag');
  });

  test('F0388DeJongButterfly presets are well-formed', () {
    final m = F0388DeJongButterfly();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0388DeJongButterfly metadata is consistent', () {
    final m = F0388DeJongButterfly();
    expect(m.metadata.id, m.id);
  });
}
