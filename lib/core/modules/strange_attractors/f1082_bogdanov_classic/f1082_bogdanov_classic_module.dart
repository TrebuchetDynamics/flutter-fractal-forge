// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1082_bogdanov_classic_presets.dart';
import 'f1082_bogdanov_classic_variants.dart';
import 'f1082_bogdanov_classic_metadata.dart';

/// Bogdanov Classic — Strange Attractors.
class F1082BogdanovClassic extends AttractorModule {
  F1082BogdanovClassic()
      : super(
          id: 'f1082_bogdanov_classic',
          shader: 'shaders/f1082_bogdanov_classic_gpu.frag',
        );

  @override
  F1082BogdanovClassicMetadata get metadata => F1082BogdanovClassicMetadata.instance;

  @override
  List<F1082BogdanovClassicPreset> get presets => F1082BogdanovClassicPresets.all;

  @override
  List<F1082BogdanovClassicVariant> get variants => F1082BogdanovClassicVariants.all;

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
