// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1047_svensson_coral_presets.dart';
import 'f1047_svensson_coral_variants.dart';
import 'f1047_svensson_coral_metadata.dart';

/// Svensson Coral — Strange Attractors.
class F1047SvenssonCoral extends AttractorModule {
  F1047SvenssonCoral()
      : super(
          id: 'f1047_svensson_coral',
          shader: 'shaders/f1047_svensson_coral_gpu.frag',
        );

  @override
  F1047SvenssonCoralMetadata get metadata => F1047SvenssonCoralMetadata.instance;

  @override
  List<F1047SvenssonCoralPreset> get presets => F1047SvenssonCoralPresets.all;

  @override
  List<F1047SvenssonCoralVariant> get variants => F1047SvenssonCoralVariants.all;

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
