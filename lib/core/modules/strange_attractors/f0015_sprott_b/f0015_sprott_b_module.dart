// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0015_sprott_b_presets.dart';
import 'f0015_sprott_b_variants.dart';
import 'f0015_sprott_b_metadata.dart';

/// Sprott B — Strange Attractors.
class F0015SprottB extends AttractorModule {
  F0015SprottB()
      : super(
          id: 'f0015_sprott_b',
          shader: 'shaders/f0015_sprott_b_gpu.frag',
        );

  @override
  F0015SprottBMetadata get metadata => F0015SprottBMetadata.instance;

  @override
  List<F0015SprottBPreset> get presets => F0015SprottBPresets.all;

  @override
  List<F0015SprottBVariant> get variants => F0015SprottBVariants.all;

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
