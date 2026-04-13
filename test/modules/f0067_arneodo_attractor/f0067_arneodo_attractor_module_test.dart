// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0067_arneodo_attractor/f0067_arneodo_attractor_module.dart';

void main() {
  test('F0067ArneodoAttractor instantiates', () {
    final m = F0067ArneodoAttractor();
    expect(m.id, 'f0067_arneodo_attractor');
    expect(m.shader, 'shaders/f0067_arneodo_attractor_gpu.frag');
  });

  test('F0067ArneodoAttractor presets are well-formed', () {
    final m = F0067ArneodoAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0067ArneodoAttractor metadata is consistent', () {
    final m = F0067ArneodoAttractor();
    expect(m.metadata.id, m.id);
  });
}
