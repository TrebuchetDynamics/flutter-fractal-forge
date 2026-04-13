// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0027_sprott_n_presets.dart';
import 'f0027_sprott_n_variants.dart';
import 'f0027_sprott_n_metadata.dart';

/// Sprott N — Strange Attractors.
class F0027SprottN extends AttractorModule {
  F0027SprottN()
      : super(
          id: 'f0027_sprott_n',
          shader: 'shaders/f0027_sprott_n_gpu.frag',
        );

  @override
  F0027SprottNMetadata get metadata => F0027SprottNMetadata.instance;

  @override
  List<F0027SprottNPreset> get presets => F0027SprottNPresets.all;

  @override
  List<F0027SprottNVariant> get variants => F0027SprottNVariants.all;

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
