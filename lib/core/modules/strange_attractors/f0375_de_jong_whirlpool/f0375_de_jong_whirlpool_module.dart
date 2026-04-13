// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0375_de_jong_whirlpool_presets.dart';
import 'f0375_de_jong_whirlpool_variants.dart';
import 'f0375_de_jong_whirlpool_metadata.dart';

/// de Jong Whirlpool — Strange Attractors.
class F0375DeJongWhirlpool extends AttractorModule {
  F0375DeJongWhirlpool()
      : super(
          id: 'f0375_de_jong_whirlpool',
          shader: 'shaders/f0375_de_jong_whirlpool_gpu.frag',
        );

  @override
  F0375DeJongWhirlpoolMetadata get metadata => F0375DeJongWhirlpoolMetadata.instance;

  @override
  List<F0375DeJongWhirlpoolPreset> get presets => F0375DeJongWhirlpoolPresets.all;

  @override
  List<F0375DeJongWhirlpoolVariant> get variants => F0375DeJongWhirlpoolVariants.all;

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
