// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1091_zaslavsky_classic_presets.dart';
import 'f1091_zaslavsky_classic_variants.dart';
import 'f1091_zaslavsky_classic_metadata.dart';

/// Zaslavsky Classic — Strange Attractors.
class F1091ZaslavskyClassic extends AttractorModule {
  F1091ZaslavskyClassic()
      : super(
          id: 'f1091_zaslavsky_classic',
          shader: 'shaders/f1091_zaslavsky_classic_gpu.frag',
        );

  @override
  F1091ZaslavskyClassicMetadata get metadata => F1091ZaslavskyClassicMetadata.instance;

  @override
  List<F1091ZaslavskyClassicPreset> get presets => F1091ZaslavskyClassicPresets.all;

  @override
  List<F1091ZaslavskyClassicVariant> get variants => F1091ZaslavskyClassicVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
