// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0058_three_scroll_unified_pan/f0058_three_scroll_unified_pan_module.dart';

void main() {
  test('F0058ThreeScrollUnifiedPan instantiates', () {
    final m = F0058ThreeScrollUnifiedPan();
    expect(m.id, 'f0058_three_scroll_unified_pan');
    expect(m.shader, 'shaders/f0058_three_scroll_unified_pan_gpu.frag');
  });

  test('F0058ThreeScrollUnifiedPan presets are well-formed', () {
    final m = F0058ThreeScrollUnifiedPan();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0058ThreeScrollUnifiedPan metadata is consistent', () {
    final m = F0058ThreeScrollUnifiedPan();
    expect(m.metadata.id, m.id);
  });
}
