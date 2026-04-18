// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1044_svensson_lace_presets.dart';
import 'f1044_svensson_lace_variants.dart';
import 'f1044_svensson_lace_metadata.dart';

/// Svensson Lace — Strange Attractors.
class F1044SvenssonLace extends AttractorModule {
  F1044SvenssonLace()
      : super(
          id: 'f1044_svensson_lace',
          shader: 'shaders/f1044_svensson_lace_gpu.frag',
        );

  @override
  F1044SvenssonLaceMetadata get metadata => F1044SvenssonLaceMetadata.instance;

  @override
  List<F1044SvenssonLacePreset> get presets => F1044SvenssonLacePresets.all;

  @override
  List<F1044SvenssonLaceVariant> get variants => F1044SvenssonLaceVariants.all;

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
