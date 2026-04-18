// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1049_svensson_net/f1049_svensson_net_module.dart';

void main() {
  test('F1049SvenssonNet instantiates', () {
    final m = F1049SvenssonNet();
    expect(m.id, 'f1049_svensson_net');
    expect(m.shader, 'shaders/f1049_svensson_net_gpu.frag');
  });

  test('F1049SvenssonNet presets are well-formed', () {
    final m = F1049SvenssonNet();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1049SvenssonNet metadata is consistent', () {
    final m = F1049SvenssonNet();
    expect(m.metadata.id, m.id);
  });
}
