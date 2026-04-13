// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0389_de_jong_flame_presets.dart';
import 'f0389_de_jong_flame_variants.dart';
import 'f0389_de_jong_flame_metadata.dart';

/// de Jong Flame — Strange Attractors.
class F0389DeJongFlame extends AttractorModule {
  F0389DeJongFlame()
      : super(
          id: 'f0389_de_jong_flame',
          shader: 'shaders/f0389_de_jong_flame_gpu.frag',
        );

  @override
  F0389DeJongFlameMetadata get metadata => F0389DeJongFlameMetadata.instance;

  @override
  List<F0389DeJongFlamePreset> get presets => F0389DeJongFlamePresets.all;

  @override
  List<F0389DeJongFlameVariant> get variants => F0389DeJongFlameVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
