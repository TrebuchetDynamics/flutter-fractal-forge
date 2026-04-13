// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0331_lenia_orbium_presets.dart';
import 'f0331_lenia_orbium_variants.dart';
import 'f0331_lenia_orbium_metadata.dart';

/// Lenia (orbium) — Cellular & Stochastic.
class F0331LeniaOrbium extends CellularModule {
  F0331LeniaOrbium()
      : super(
          id: 'f0331_lenia_orbium',
          shader: 'shaders/f0331_lenia_orbium_gpu.frag',
        );

  @override
  F0331LeniaOrbiumMetadata get metadata => F0331LeniaOrbiumMetadata.instance;

  @override
  List<F0331LeniaOrbiumPreset> get presets => F0331LeniaOrbiumPresets.all;

  @override
  List<F0331LeniaOrbiumVariant> get variants => F0331LeniaOrbiumVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
