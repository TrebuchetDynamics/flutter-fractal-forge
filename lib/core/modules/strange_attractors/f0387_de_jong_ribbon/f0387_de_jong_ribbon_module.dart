// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0387_de_jong_ribbon_presets.dart';
import 'f0387_de_jong_ribbon_variants.dart';
import 'f0387_de_jong_ribbon_metadata.dart';

/// de Jong Ribbon — Strange Attractors.
class F0387DeJongRibbon extends AttractorModule {
  F0387DeJongRibbon()
      : super(
          id: 'f0387_de_jong_ribbon',
          shader: 'shaders/f0387_de_jong_ribbon_gpu.frag',
        );

  @override
  F0387DeJongRibbonMetadata get metadata => F0387DeJongRibbonMetadata.instance;

  @override
  List<F0387DeJongRibbonPreset> get presets => F0387DeJongRibbonPresets.all;

  @override
  List<F0387DeJongRibbonVariant> get variants => F0387DeJongRibbonVariants.all;

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
