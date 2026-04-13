// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0381_de_jong_double_presets.dart';
import 'f0381_de_jong_double_variants.dart';
import 'f0381_de_jong_double_metadata.dart';

/// de Jong Double — Strange Attractors.
class F0381DeJongDouble extends AttractorModule {
  F0381DeJongDouble()
      : super(
          id: 'f0381_de_jong_double',
          shader: 'shaders/f0381_de_jong_double_gpu.frag',
        );

  @override
  F0381DeJongDoubleMetadata get metadata => F0381DeJongDoubleMetadata.instance;

  @override
  List<F0381DeJongDoublePreset> get presets => F0381DeJongDoublePresets.all;

  @override
  List<F0381DeJongDoubleVariant> get variants => F0381DeJongDoubleVariants.all;

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
