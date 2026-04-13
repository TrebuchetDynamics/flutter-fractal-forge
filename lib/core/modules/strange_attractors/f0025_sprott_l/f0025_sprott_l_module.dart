// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0025_sprott_l_presets.dart';
import 'f0025_sprott_l_variants.dart';
import 'f0025_sprott_l_metadata.dart';

/// Sprott L — Strange Attractors.
class F0025SprottL extends AttractorModule {
  F0025SprottL()
      : super(
          id: 'f0025_sprott_l',
          shader: 'shaders/f0025_sprott_l_gpu.frag',
        );

  @override
  F0025SprottLMetadata get metadata => F0025SprottLMetadata.instance;

  @override
  List<F0025SprottLPreset> get presets => F0025SprottLPresets.all;

  @override
  List<F0025SprottLVariant> get variants => F0025SprottLVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
