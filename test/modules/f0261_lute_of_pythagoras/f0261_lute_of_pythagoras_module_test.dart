// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0261_lute_of_pythagoras/f0261_lute_of_pythagoras_module.dart';

void main() {
  test('F0261LuteOfPythagoras instantiates', () {
    final m = F0261LuteOfPythagoras();
    expect(m.id, 'f0261_lute_of_pythagoras');
    expect(m.shader, 'shaders/f0261_lute_of_pythagoras_gpu.frag');
  });

  test('F0261LuteOfPythagoras presets are well-formed', () {
    final m = F0261LuteOfPythagoras();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0261LuteOfPythagoras metadata is consistent', () {
    final m = F0261LuteOfPythagoras();
    expect(m.metadata.id, m.id);
  });
}
