// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0217_belykh_map_presets.dart';
import 'f0217_belykh_map_variants.dart';
import 'f0217_belykh_map_metadata.dart';

/// Belykh Map — Strange Attractors.
class F0217BelykhMap extends AttractorModule {
  F0217BelykhMap()
      : super(
          id: 'f0217_belykh_map',
          shader: 'shaders/f0217_belykh_map_gpu.frag',
        );

  @override
  F0217BelykhMapMetadata get metadata => F0217BelykhMapMetadata.instance;

  @override
  List<F0217BelykhMapPreset> get presets => F0217BelykhMapPresets.all;

  @override
  List<F0217BelykhMapVariant> get variants => F0217BelykhMapVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
