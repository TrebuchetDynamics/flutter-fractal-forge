// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0990_anneal_b4678_s35678/f0990_anneal_b4678_s35678_module.dart';

void main() {
  test('F0990AnnealB4678S35678 instantiates', () {
    final m = F0990AnnealB4678S35678();
    expect(m.id, 'f0990_anneal_b4678_s35678');
    expect(m.shader, 'shaders/f0990_anneal_b4678_s35678_gpu.frag');
  });

  test('F0990AnnealB4678S35678 presets are well-formed', () {
    final m = F0990AnnealB4678S35678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0990AnnealB4678S35678 metadata is consistent', () {
    final m = F0990AnnealB4678S35678();
    expect(m.metadata.id, m.id);
  });
}
