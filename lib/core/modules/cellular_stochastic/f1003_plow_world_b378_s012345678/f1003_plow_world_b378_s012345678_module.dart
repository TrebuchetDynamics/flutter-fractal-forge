// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1003_plow_world_b378_s012345678_presets.dart';
import 'f1003_plow_world_b378_s012345678_variants.dart';
import 'f1003_plow_world_b378_s012345678_metadata.dart';

/// Plow World (B378/S012345678) — Cellular & Stochastic.
class F1003PlowWorldB378S012345678 extends CellularModule {
  F1003PlowWorldB378S012345678()
      : super(
          id: 'f1003_plow_world_b378_s012345678',
          shader: 'shaders/f1003_plow_world_b378_s012345678_gpu.frag',
        );

  @override
  F1003PlowWorldB378S012345678Metadata get metadata => F1003PlowWorldB378S012345678Metadata.instance;

  @override
  List<F1003PlowWorldB378S012345678Preset> get presets => F1003PlowWorldB378S012345678Presets.all;

  @override
  List<F1003PlowWorldB378S012345678Variant> get variants => F1003PlowWorldB378S012345678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
