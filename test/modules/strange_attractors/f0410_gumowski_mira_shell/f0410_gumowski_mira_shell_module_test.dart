// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0410_gumowski_mira_shell/f0410_gumowski_mira_shell_module.dart';

void main() {
  test('F0410GumowskiMiraShell instantiates', () {
    final m = F0410GumowskiMiraShell();
    expect(m.id, 'f0410_gumowski_mira_shell');
    expect(m.shader, 'shaders/f0410_gumowski_mira_shell_gpu.frag');
  });

  test('F0410GumowskiMiraShell presets are well-formed', () {
    final m = F0410GumowskiMiraShell();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0410GumowskiMiraShell metadata is consistent', () {
    final m = F0410GumowskiMiraShell();
    expect(m.metadata.id, m.id);
  });
}
