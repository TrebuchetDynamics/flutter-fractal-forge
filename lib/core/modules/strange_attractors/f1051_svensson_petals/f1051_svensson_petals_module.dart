// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1051_svensson_petals_presets.dart';
import 'f1051_svensson_petals_variants.dart';
import 'f1051_svensson_petals_metadata.dart';

/// Svensson Petals — Strange Attractors.
class F1051SvenssonPetals extends AttractorModule {
  F1051SvenssonPetals()
      : super(
          id: 'f1051_svensson_petals',
          shader: 'shaders/f1051_svensson_petals_gpu.frag',
        );

  @override
  F1051SvenssonPetalsMetadata get metadata => F1051SvenssonPetalsMetadata.instance;

  @override
  List<F1051SvenssonPetalsPreset> get presets => F1051SvenssonPetalsPresets.all;

  @override
  List<F1051SvenssonPetalsVariant> get variants => F1051SvenssonPetalsVariants.all;

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
