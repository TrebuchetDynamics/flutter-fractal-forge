// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0370_de_jong_classic_presets.dart';
import 'f0370_de_jong_classic_variants.dart';
import 'f0370_de_jong_classic_metadata.dart';

/// de Jong Classic — Strange Attractors.
class F0370DeJongClassic extends AttractorModule {
  F0370DeJongClassic()
      : super(
          id: 'f0370_de_jong_classic',
          shader: 'shaders/f0370_de_jong_classic_gpu.frag',
        );

  @override
  F0370DeJongClassicMetadata get metadata => F0370DeJongClassicMetadata.instance;

  @override
  List<F0370DeJongClassicPreset> get presets => F0370DeJongClassicPresets.all;

  @override
  List<F0370DeJongClassicVariant> get variants => F0370DeJongClassicVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
