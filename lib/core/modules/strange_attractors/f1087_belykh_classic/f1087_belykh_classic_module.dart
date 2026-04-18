// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1087_belykh_classic_presets.dart';
import 'f1087_belykh_classic_variants.dart';
import 'f1087_belykh_classic_metadata.dart';

/// Belykh Classic — Strange Attractors.
class F1087BelykhClassic extends AttractorModule {
  F1087BelykhClassic()
      : super(
          id: 'f1087_belykh_classic',
          shader: 'shaders/f1087_belykh_classic_gpu.frag',
        );

  @override
  F1087BelykhClassicMetadata get metadata => F1087BelykhClassicMetadata.instance;

  @override
  List<F1087BelykhClassicPreset> get presets => F1087BelykhClassicPresets.all;

  @override
  List<F1087BelykhClassicVariant> get variants => F1087BelykhClassicVariants.all;

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
