// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1060_svensson_fan_presets.dart';
import 'f1060_svensson_fan_variants.dart';
import 'f1060_svensson_fan_metadata.dart';

/// Svensson Fan — Strange Attractors.
class F1060SvenssonFan extends AttractorModule {
  F1060SvenssonFan()
      : super(
          id: 'f1060_svensson_fan',
          shader: 'shaders/f1060_svensson_fan_gpu.frag',
        );

  @override
  F1060SvenssonFanMetadata get metadata => F1060SvenssonFanMetadata.instance;

  @override
  List<F1060SvenssonFanPreset> get presets => F1060SvenssonFanPresets.all;

  @override
  List<F1060SvenssonFanVariant> get variants => F1060SvenssonFanVariants.all;

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
