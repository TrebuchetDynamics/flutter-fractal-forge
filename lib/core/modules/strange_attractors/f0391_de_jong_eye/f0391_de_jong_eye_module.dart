// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0391_de_jong_eye_presets.dart';
import 'f0391_de_jong_eye_variants.dart';
import 'f0391_de_jong_eye_metadata.dart';

/// de Jong Eye — Strange Attractors.
class F0391DeJongEye extends AttractorModule {
  F0391DeJongEye()
      : super(
          id: 'f0391_de_jong_eye',
          shader: 'shaders/f0391_de_jong_eye_gpu.frag',
        );

  @override
  F0391DeJongEyeMetadata get metadata => F0391DeJongEyeMetadata.instance;

  @override
  List<F0391DeJongEyePreset> get presets => F0391DeJongEyePresets.all;

  @override
  List<F0391DeJongEyeVariant> get variants => F0391DeJongEyeVariants.all;

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
