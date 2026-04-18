// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0767_bolzano_non_differentiable_presets.dart';
import 'f0767_bolzano_non_differentiable_variants.dart';
import 'f0767_bolzano_non_differentiable_metadata.dart';

/// Bolzano Non-Differentiable — Number-Theory Fractals.
class F0767BolzanoNonDifferentiable extends CellularModule {
  F0767BolzanoNonDifferentiable()
      : super(
          id: 'f0767_bolzano_non_differentiable',
          shader: 'shaders/f0767_bolzano_non_differentiable_gpu.frag',
        );

  @override
  F0767BolzanoNonDifferentiableMetadata get metadata => F0767BolzanoNonDifferentiableMetadata.instance;

  @override
  List<F0767BolzanoNonDifferentiablePreset> get presets => F0767BolzanoNonDifferentiablePresets.all;

  @override
  List<F0767BolzanoNonDifferentiableVariant> get variants => F0767BolzanoNonDifferentiableVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
