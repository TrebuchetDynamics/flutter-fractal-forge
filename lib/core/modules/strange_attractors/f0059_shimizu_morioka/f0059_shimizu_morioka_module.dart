// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0059_shimizu_morioka_presets.dart';
import 'f0059_shimizu_morioka_variants.dart';
import 'f0059_shimizu_morioka_metadata.dart';

/// Shimizu-Morioka — Strange Attractors.
class F0059ShimizuMorioka extends AttractorModule {
  F0059ShimizuMorioka()
      : super(
          id: 'f0059_shimizu_morioka',
          shader: 'shaders/f0059_shimizu_morioka_gpu.frag',
        );

  @override
  F0059ShimizuMoriokaMetadata get metadata => F0059ShimizuMoriokaMetadata.instance;

  @override
  List<F0059ShimizuMoriokaPreset> get presets => F0059ShimizuMoriokaPresets.all;

  @override
  List<F0059ShimizuMoriokaVariant> get variants => F0059ShimizuMoriokaVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
