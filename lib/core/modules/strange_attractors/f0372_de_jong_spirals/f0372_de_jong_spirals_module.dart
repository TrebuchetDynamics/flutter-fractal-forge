// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0372_de_jong_spirals_presets.dart';
import 'f0372_de_jong_spirals_variants.dart';
import 'f0372_de_jong_spirals_metadata.dart';

/// de Jong Spirals — Strange Attractors.
class F0372DeJongSpirals extends AttractorModule {
  F0372DeJongSpirals()
      : super(
          id: 'f0372_de_jong_spirals',
          shader: 'shaders/f0372_de_jong_spirals_gpu.frag',
        );

  @override
  F0372DeJongSpiralsMetadata get metadata => F0372DeJongSpiralsMetadata.instance;

  @override
  List<F0372DeJongSpiralsPreset> get presets => F0372DeJongSpiralsPresets.all;

  @override
  List<F0372DeJongSpiralsVariant> get variants => F0372DeJongSpiralsVariants.all;

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
