// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1049_svensson_net_presets.dart';
import 'f1049_svensson_net_variants.dart';
import 'f1049_svensson_net_metadata.dart';

/// Svensson Net — Strange Attractors.
class F1049SvenssonNet extends AttractorModule {
  F1049SvenssonNet()
      : super(
          id: 'f1049_svensson_net',
          shader: 'shaders/f1049_svensson_net_gpu.frag',
        );

  @override
  F1049SvenssonNetMetadata get metadata => F1049SvenssonNetMetadata.instance;

  @override
  List<F1049SvenssonNetPreset> get presets => F1049SvenssonNetPresets.all;

  @override
  List<F1049SvenssonNetVariant> get variants => F1049SvenssonNetVariants.all;

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
