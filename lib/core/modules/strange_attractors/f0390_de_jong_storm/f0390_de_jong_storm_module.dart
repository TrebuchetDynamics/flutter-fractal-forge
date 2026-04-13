// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0390_de_jong_storm_presets.dart';
import 'f0390_de_jong_storm_variants.dart';
import 'f0390_de_jong_storm_metadata.dart';

/// de Jong Storm — Strange Attractors.
class F0390DeJongStorm extends AttractorModule {
  F0390DeJongStorm()
      : super(
          id: 'f0390_de_jong_storm',
          shader: 'shaders/f0390_de_jong_storm_gpu.frag',
        );

  @override
  F0390DeJongStormMetadata get metadata => F0390DeJongStormMetadata.instance;

  @override
  List<F0390DeJongStormPreset> get presets => F0390DeJongStormPresets.all;

  @override
  List<F0390DeJongStormVariant> get variants => F0390DeJongStormVariants.all;

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
