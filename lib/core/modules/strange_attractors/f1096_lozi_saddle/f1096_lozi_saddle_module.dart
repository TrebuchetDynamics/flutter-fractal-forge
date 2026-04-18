// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1096_lozi_saddle_presets.dart';
import 'f1096_lozi_saddle_variants.dart';
import 'f1096_lozi_saddle_metadata.dart';

/// Lozi Saddle — Strange Attractors.
class F1096LoziSaddle extends AttractorModule {
  F1096LoziSaddle()
      : super(
          id: 'f1096_lozi_saddle',
          shader: 'shaders/f1096_lozi_saddle_gpu.frag',
        );

  @override
  F1096LoziSaddleMetadata get metadata => F1096LoziSaddleMetadata.instance;

  @override
  List<F1096LoziSaddlePreset> get presets => F1096LoziSaddlePresets.all;

  @override
  List<F1096LoziSaddleVariant> get variants => F1096LoziSaddleVariants.all;

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
