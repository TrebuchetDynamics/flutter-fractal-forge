// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0021_sprott_h_presets.dart';
import 'f0021_sprott_h_variants.dart';
import 'f0021_sprott_h_metadata.dart';

/// Sprott H — Strange Attractors.
class F0021SprottH extends AttractorModule {
  F0021SprottH()
      : super(
          id: 'f0021_sprott_h',
          shader: 'shaders/f0021_sprott_h_gpu.frag',
        );

  @override
  F0021SprottHMetadata get metadata => F0021SprottHMetadata.instance;

  @override
  List<F0021SprottHPreset> get presets => F0021SprottHPresets.all;

  @override
  List<F0021SprottHVariant> get variants => F0021SprottHVariants.all;

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
