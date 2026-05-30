// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0390_de_jong_storm/f0390_de_jong_storm_module.dart';

void main() {
  test('F0390DeJongStorm instantiates', () {
    final m = F0390DeJongStorm();
    expect(m.id, 'f0390_de_jong_storm');
    expect(m.shader, 'shaders/f0390_de_jong_storm_gpu.frag');
  });

  test('F0390DeJongStorm presets are well-formed', () {
    final m = F0390DeJongStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0390DeJongStorm metadata is consistent', () {
    final m = F0390DeJongStorm();
    expect(m.metadata.id, m.id);
  });
}
