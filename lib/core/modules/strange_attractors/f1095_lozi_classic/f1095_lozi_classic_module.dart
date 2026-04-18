// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1095_lozi_classic_presets.dart';
import 'f1095_lozi_classic_variants.dart';
import 'f1095_lozi_classic_metadata.dart';

/// Lozi Classic — Strange Attractors.
class F1095LoziClassic extends AttractorModule {
  F1095LoziClassic()
      : super(
          id: 'f1095_lozi_classic',
          shader: 'shaders/f1095_lozi_classic_gpu.frag',
        );

  @override
  F1095LoziClassicMetadata get metadata => F1095LoziClassicMetadata.instance;

  @override
  List<F1095LoziClassicPreset> get presets => F1095LoziClassicPresets.all;

  @override
  List<F1095LoziClassicVariant> get variants => F1095LoziClassicVariants.all;

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
