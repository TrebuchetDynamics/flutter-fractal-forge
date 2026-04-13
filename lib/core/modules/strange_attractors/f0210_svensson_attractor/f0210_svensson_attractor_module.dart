// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0210_svensson_attractor_presets.dart';
import 'f0210_svensson_attractor_variants.dart';
import 'f0210_svensson_attractor_metadata.dart';

/// Svensson Attractor — Strange Attractors.
class F0210SvenssonAttractor extends AttractorModule {
  F0210SvenssonAttractor()
      : super(
          id: 'f0210_svensson_attractor',
          shader: 'shaders/f0210_svensson_attractor_gpu.frag',
        );

  @override
  F0210SvenssonAttractorMetadata get metadata => F0210SvenssonAttractorMetadata.instance;

  @override
  List<F0210SvenssonAttractorPreset> get presets => F0210SvenssonAttractorPresets.all;

  @override
  List<F0210SvenssonAttractorVariant> get variants => F0210SvenssonAttractorVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
