// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1054_svensson_halo_presets.dart';
import 'f1054_svensson_halo_variants.dart';
import 'f1054_svensson_halo_metadata.dart';

/// Svensson Halo — Strange Attractors.
class F1054SvenssonHalo extends AttractorModule {
  F1054SvenssonHalo()
      : super(
          id: 'f1054_svensson_halo',
          shader: 'shaders/f1054_svensson_halo_gpu.frag',
        );

  @override
  F1054SvenssonHaloMetadata get metadata => F1054SvenssonHaloMetadata.instance;

  @override
  List<F1054SvenssonHaloPreset> get presets => F1054SvenssonHaloPresets.all;

  @override
  List<F1054SvenssonHaloVariant> get variants => F1054SvenssonHaloVariants.all;

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
