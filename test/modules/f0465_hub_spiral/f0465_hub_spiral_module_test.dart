// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0465_hub_spiral/f0465_hub_spiral_module.dart';

void main() {
  test('F0465HubSpiral instantiates', () {
    final m = F0465HubSpiral();
    expect(m.id, 'f0465_hub_spiral');
    expect(m.shader, 'shaders/f0465_hub_spiral_gpu.frag');
  });

  test('F0465HubSpiral presets are well-formed', () {
    final m = F0465HubSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0465HubSpiral metadata is consistent', () {
    final m = F0465HubSpiral();
    expect(m.metadata.id, m.id);
  });
}
