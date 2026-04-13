// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0040_sprott_linz_h_presets.dart';
import 'f0040_sprott_linz_h_variants.dart';
import 'f0040_sprott_linz_h_metadata.dart';

/// Sprott-Linz H — Strange Attractors.
class F0040SprottLinzH extends AttractorModule {
  F0040SprottLinzH()
      : super(
          id: 'f0040_sprott_linz_h',
          shader: 'shaders/f0040_sprott_linz_h_gpu.frag',
        );

  @override
  F0040SprottLinzHMetadata get metadata => F0040SprottLinzHMetadata.instance;

  @override
  List<F0040SprottLinzHPreset> get presets => F0040SprottLinzHPresets.all;

  @override
  List<F0040SprottLinzHVariant> get variants => F0040SprottLinzHVariants.all;

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
