// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0748_oregonator_3_variable_presets.dart';
import 'f0748_oregonator_3_variable_variants.dart';
import 'f0748_oregonator_3_variable_metadata.dart';

/// Oregonator (3-variable) — Reaction-Diffusion & Chemical.
class F0748Oregonator3Variable extends CellularModule {
  F0748Oregonator3Variable()
      : super(
          id: 'f0748_oregonator_3_variable',
          shader: 'shaders/f0748_oregonator_3_variable_gpu.frag',
        );

  @override
  F0748Oregonator3VariableMetadata get metadata => F0748Oregonator3VariableMetadata.instance;

  @override
  List<F0748Oregonator3VariablePreset> get presets => F0748Oregonator3VariablePresets.all;

  @override
  List<F0748Oregonator3VariableVariant> get variants => F0748Oregonator3VariableVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
