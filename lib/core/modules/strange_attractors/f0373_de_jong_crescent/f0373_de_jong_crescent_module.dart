// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0373_de_jong_crescent_presets.dart';
import 'f0373_de_jong_crescent_variants.dart';
import 'f0373_de_jong_crescent_metadata.dart';

/// de Jong Crescent — Strange Attractors.
class F0373DeJongCrescent extends AttractorModule {
  F0373DeJongCrescent()
      : super(
          id: 'f0373_de_jong_crescent',
          shader: 'shaders/f0373_de_jong_crescent_gpu.frag',
        );

  @override
  F0373DeJongCrescentMetadata get metadata => F0373DeJongCrescentMetadata.instance;

  @override
  List<F0373DeJongCrescentPreset> get presets => F0373DeJongCrescentPresets.all;

  @override
  List<F0373DeJongCrescentVariant> get variants => F0373DeJongCrescentVariants.all;

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
