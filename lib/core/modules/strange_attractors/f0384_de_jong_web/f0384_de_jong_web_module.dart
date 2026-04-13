// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0384_de_jong_web_presets.dart';
import 'f0384_de_jong_web_variants.dart';
import 'f0384_de_jong_web_metadata.dart';

/// de Jong Web — Strange Attractors.
class F0384DeJongWeb extends AttractorModule {
  F0384DeJongWeb()
      : super(
          id: 'f0384_de_jong_web',
          shader: 'shaders/f0384_de_jong_web_gpu.frag',
        );

  @override
  F0384DeJongWebMetadata get metadata => F0384DeJongWebMetadata.instance;

  @override
  List<F0384DeJongWebPreset> get presets => F0384DeJongWebPresets.all;

  @override
  List<F0384DeJongWebVariant> get variants => F0384DeJongWebVariants.all;

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
