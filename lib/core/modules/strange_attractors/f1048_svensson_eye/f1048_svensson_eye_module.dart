// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1048_svensson_eye_presets.dart';
import 'f1048_svensson_eye_variants.dart';
import 'f1048_svensson_eye_metadata.dart';

/// Svensson Eye — Strange Attractors.
class F1048SvenssonEye extends AttractorModule {
  F1048SvenssonEye()
      : super(
          id: 'f1048_svensson_eye',
          shader: 'shaders/f1048_svensson_eye_gpu.frag',
        );

  @override
  F1048SvenssonEyeMetadata get metadata => F1048SvenssonEyeMetadata.instance;

  @override
  List<F1048SvenssonEyePreset> get presets => F1048SvenssonEyePresets.all;

  @override
  List<F1048SvenssonEyeVariant> get variants => F1048SvenssonEyeVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
