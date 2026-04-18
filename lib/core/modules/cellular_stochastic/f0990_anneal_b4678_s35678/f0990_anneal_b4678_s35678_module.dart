// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0990_anneal_b4678_s35678_presets.dart';
import 'f0990_anneal_b4678_s35678_variants.dart';
import 'f0990_anneal_b4678_s35678_metadata.dart';

/// Anneal (B4678/S35678) — Cellular & Stochastic.
class F0990AnnealB4678S35678 extends CellularModule {
  F0990AnnealB4678S35678()
      : super(
          id: 'f0990_anneal_b4678_s35678',
          shader: 'shaders/f0990_anneal_b4678_s35678_gpu.frag',
        );

  @override
  F0990AnnealB4678S35678Metadata get metadata => F0990AnnealB4678S35678Metadata.instance;

  @override
  List<F0990AnnealB4678S35678Preset> get presets => F0990AnnealB4678S35678Presets.all;

  @override
  List<F0990AnnealB4678S35678Variant> get variants => F0990AnnealB4678S35678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
