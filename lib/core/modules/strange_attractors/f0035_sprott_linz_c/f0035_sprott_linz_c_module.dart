// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0035_sprott_linz_c_presets.dart';
import 'f0035_sprott_linz_c_variants.dart';
import 'f0035_sprott_linz_c_metadata.dart';

/// Sprott-Linz C — Strange Attractors.
class F0035SprottLinzC extends AttractorModule {
  F0035SprottLinzC()
      : super(
          id: 'f0035_sprott_linz_c',
          shader: 'shaders/f0035_sprott_linz_c_gpu.frag',
        );

  @override
  F0035SprottLinzCMetadata get metadata => F0035SprottLinzCMetadata.instance;

  @override
  List<F0035SprottLinzCPreset> get presets => F0035SprottLinzCPresets.all;

  @override
  List<F0035SprottLinzCVariant> get variants => F0035SprottLinzCVariants.all;

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
