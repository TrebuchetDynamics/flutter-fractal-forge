// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0830_bungalow_period_doubling_presets.dart';
import 'f0830_bungalow_period_doubling_variants.dart';
import 'f0830_bungalow_period_doubling_metadata.dart';

/// Bungalow (Period-doubling) — Strange Attractors.
class F0830BungalowPeriodDoubling extends AttractorModule {
  F0830BungalowPeriodDoubling()
      : super(
          id: 'f0830_bungalow_period_doubling',
          shader: 'shaders/f0830_bungalow_period_doubling_gpu.frag',
        );

  @override
  F0830BungalowPeriodDoublingMetadata get metadata => F0830BungalowPeriodDoublingMetadata.instance;

  @override
  List<F0830BungalowPeriodDoublingPreset> get presets => F0830BungalowPeriodDoublingPresets.all;

  @override
  List<F0830BungalowPeriodDoublingVariant> get variants => F0830BungalowPeriodDoublingVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
