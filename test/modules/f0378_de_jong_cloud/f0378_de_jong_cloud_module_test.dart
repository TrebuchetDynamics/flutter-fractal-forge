// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0378_de_jong_cloud/f0378_de_jong_cloud_module.dart';

void main() {
  test('F0378DeJongCloud instantiates', () {
    final m = F0378DeJongCloud();
    expect(m.id, 'f0378_de_jong_cloud');
    expect(m.shader, 'shaders/f0378_de_jong_cloud_gpu.frag');
  });

  test('F0378DeJongCloud presets are well-formed', () {
    final m = F0378DeJongCloud();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0378DeJongCloud metadata is consistent', () {
    final m = F0378DeJongCloud();
    expect(m.metadata.id, m.id);
  });
}
