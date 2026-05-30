// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0481_shepherd_s_crook/f0481_shepherd_s_crook_module.dart';

void main() {
  test('F0481ShepherdSCrook instantiates', () {
    final m = F0481ShepherdSCrook();
    expect(m.id, 'f0481_shepherd_s_crook');
    expect(m.shader, 'shaders/f0481_shepherd_s_crook_gpu.frag');
  });

  test('F0481ShepherdSCrook presets are well-formed', () {
    final m = F0481ShepherdSCrook();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0481ShepherdSCrook metadata is consistent', () {
    final m = F0481ShepherdSCrook();
    expect(m.metadata.id, m.id);
  });
}
