// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0396_icon_emperor/f0396_icon_emperor_module.dart';

void main() {
  test('F0396IconEmperor instantiates', () {
    final m = F0396IconEmperor();
    expect(m.id, 'f0396_icon_emperor');
    expect(m.shader, 'shaders/f0396_icon_emperor_gpu.frag');
  });

  test('F0396IconEmperor presets are well-formed', () {
    final m = F0396IconEmperor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0396IconEmperor metadata is consistent', () {
    final m = F0396IconEmperor();
    expect(m.metadata.id, m.id);
  });
}
