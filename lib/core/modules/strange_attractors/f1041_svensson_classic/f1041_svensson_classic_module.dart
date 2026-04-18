// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1041_svensson_classic_presets.dart';
import 'f1041_svensson_classic_variants.dart';
import 'f1041_svensson_classic_metadata.dart';

/// Svensson Classic — Strange Attractors.
class F1041SvenssonClassic extends AttractorModule {
  F1041SvenssonClassic()
      : super(
          id: 'f1041_svensson_classic',
          shader: 'shaders/f1041_svensson_classic_gpu.frag',
        );

  @override
  F1041SvenssonClassicMetadata get metadata => F1041SvenssonClassicMetadata.instance;

  @override
  List<F1041SvenssonClassicPreset> get presets => F1041SvenssonClassicPresets.all;

  @override
  List<F1041SvenssonClassicVariant> get variants => F1041SvenssonClassicVariants.all;

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
