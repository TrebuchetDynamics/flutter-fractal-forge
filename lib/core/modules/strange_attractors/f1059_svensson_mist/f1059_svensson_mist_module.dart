// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1059_svensson_mist_presets.dart';
import 'f1059_svensson_mist_variants.dart';
import 'f1059_svensson_mist_metadata.dart';

/// Svensson Mist — Strange Attractors.
class F1059SvenssonMist extends AttractorModule {
  F1059SvenssonMist()
      : super(
          id: 'f1059_svensson_mist',
          shader: 'shaders/f1059_svensson_mist_gpu.frag',
        );

  @override
  F1059SvenssonMistMetadata get metadata => F1059SvenssonMistMetadata.instance;

  @override
  List<F1059SvenssonMistPreset> get presets => F1059SvenssonMistPresets.all;

  @override
  List<F1059SvenssonMistVariant> get variants => F1059SvenssonMistVariants.all;

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
