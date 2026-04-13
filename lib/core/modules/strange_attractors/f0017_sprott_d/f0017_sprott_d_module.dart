// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0017_sprott_d_presets.dart';
import 'f0017_sprott_d_variants.dart';
import 'f0017_sprott_d_metadata.dart';

/// Sprott D — Strange Attractors.
class F0017SprottD extends AttractorModule {
  F0017SprottD()
      : super(
          id: 'f0017_sprott_d',
          shader: 'shaders/f0017_sprott_d_gpu.frag',
        );

  @override
  F0017SprottDMetadata get metadata => F0017SprottDMetadata.instance;

  @override
  List<F0017SprottDPreset> get presets => F0017SprottDPresets.all;

  @override
  List<F0017SprottDVariant> get variants => F0017SprottDVariants.all;

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
