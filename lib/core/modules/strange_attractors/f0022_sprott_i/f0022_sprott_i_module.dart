// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0022_sprott_i_presets.dart';
import 'f0022_sprott_i_variants.dart';
import 'f0022_sprott_i_metadata.dart';

/// Sprott I — Strange Attractors.
class F0022SprottI extends AttractorModule {
  F0022SprottI()
      : super(
          id: 'f0022_sprott_i',
          shader: 'shaders/f0022_sprott_i_gpu.frag',
        );

  @override
  F0022SprottIMetadata get metadata => F0022SprottIMetadata.instance;

  @override
  List<F0022SprottIPreset> get presets => F0022SprottIPresets.all;

  @override
  List<F0022SprottIVariant> get variants => F0022SprottIVariants.all;

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
