// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0816_gauss_iteration_map_presets.dart';
import 'f0816_gauss_iteration_map_variants.dart';
import 'f0816_gauss_iteration_map_metadata.dart';

/// Gauss Iteration Map — Strange Attractors.
class F0816GaussIterationMap extends AttractorModule {
  F0816GaussIterationMap()
      : super(
          id: 'f0816_gauss_iteration_map',
          shader: 'shaders/f0816_gauss_iteration_map_gpu.frag',
        );

  @override
  F0816GaussIterationMapMetadata get metadata => F0816GaussIterationMapMetadata.instance;

  @override
  List<F0816GaussIterationMapPreset> get presets => F0816GaussIterationMapPresets.all;

  @override
  List<F0816GaussIterationMapVariant> get variants => F0816GaussIterationMapVariants.all;

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
