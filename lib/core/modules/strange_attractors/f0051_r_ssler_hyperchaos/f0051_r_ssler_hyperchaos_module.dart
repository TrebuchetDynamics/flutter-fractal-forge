// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0051_r_ssler_hyperchaos_presets.dart';
import 'f0051_r_ssler_hyperchaos_variants.dart';
import 'f0051_r_ssler_hyperchaos_metadata.dart';

/// Rössler Hyperchaos — Strange Attractors.
class F0051RSslerHyperchaos extends AttractorModule {
  F0051RSslerHyperchaos()
      : super(
          id: 'f0051_r_ssler_hyperchaos',
          shader: 'shaders/f0051_r_ssler_hyperchaos_gpu.frag',
        );

  @override
  F0051RSslerHyperchaosMetadata get metadata => F0051RSslerHyperchaosMetadata.instance;

  @override
  List<F0051RSslerHyperchaosPreset> get presets => F0051RSslerHyperchaosPresets.all;

  @override
  List<F0051RSslerHyperchaosVariant> get variants => F0051RSslerHyperchaosVariants.all;

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
