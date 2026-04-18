// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1055_svensson_cyclone_presets.dart';
import 'f1055_svensson_cyclone_variants.dart';
import 'f1055_svensson_cyclone_metadata.dart';

/// Svensson Cyclone — Strange Attractors.
class F1055SvenssonCyclone extends AttractorModule {
  F1055SvenssonCyclone()
      : super(
          id: 'f1055_svensson_cyclone',
          shader: 'shaders/f1055_svensson_cyclone_gpu.frag',
        );

  @override
  F1055SvenssonCycloneMetadata get metadata => F1055SvenssonCycloneMetadata.instance;

  @override
  List<F1055SvenssonCyclonePreset> get presets => F1055SvenssonCyclonePresets.all;

  @override
  List<F1055SvenssonCycloneVariant> get variants => F1055SvenssonCycloneVariants.all;

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
