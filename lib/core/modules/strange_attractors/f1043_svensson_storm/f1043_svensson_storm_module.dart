// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1043_svensson_storm_presets.dart';
import 'f1043_svensson_storm_variants.dart';
import 'f1043_svensson_storm_metadata.dart';

/// Svensson Storm — Strange Attractors.
class F1043SvenssonStorm extends AttractorModule {
  F1043SvenssonStorm()
      : super(
          id: 'f1043_svensson_storm',
          shader: 'shaders/f1043_svensson_storm_gpu.frag',
        );

  @override
  F1043SvenssonStormMetadata get metadata => F1043SvenssonStormMetadata.instance;

  @override
  List<F1043SvenssonStormPreset> get presets => F1043SvenssonStormPresets.all;

  @override
  List<F1043SvenssonStormVariant> get variants => F1043SvenssonStormVariants.all;

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
