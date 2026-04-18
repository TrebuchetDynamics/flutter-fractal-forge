// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1090_belykh_saddle_presets.dart';
import 'f1090_belykh_saddle_variants.dart';
import 'f1090_belykh_saddle_metadata.dart';

/// Belykh Saddle — Strange Attractors.
class F1090BelykhSaddle extends AttractorModule {
  F1090BelykhSaddle()
      : super(
          id: 'f1090_belykh_saddle',
          shader: 'shaders/f1090_belykh_saddle_gpu.frag',
        );

  @override
  F1090BelykhSaddleMetadata get metadata => F1090BelykhSaddleMetadata.instance;

  @override
  List<F1090BelykhSaddlePreset> get presets => F1090BelykhSaddlePresets.all;

  @override
  List<F1090BelykhSaddleVariant> get variants => F1090BelykhSaddleVariants.all;

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
