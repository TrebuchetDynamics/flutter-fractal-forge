// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0827_smale_horseshoe_presets.dart';
import 'f0827_smale_horseshoe_variants.dart';
import 'f0827_smale_horseshoe_metadata.dart';

/// Smale Horseshoe — Strange Attractors.
class F0827SmaleHorseshoe extends AttractorModule {
  F0827SmaleHorseshoe()
      : super(
          id: 'f0827_smale_horseshoe',
          shader: 'shaders/f0827_smale_horseshoe_gpu.frag',
        );

  @override
  F0827SmaleHorseshoeMetadata get metadata => F0827SmaleHorseshoeMetadata.instance;

  @override
  List<F0827SmaleHorseshoePreset> get presets => F0827SmaleHorseshoePresets.all;

  @override
  List<F0827SmaleHorseshoeVariant> get variants => F0827SmaleHorseshoeVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
