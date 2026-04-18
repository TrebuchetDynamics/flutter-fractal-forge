// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1050_svensson_bay_presets.dart';
import 'f1050_svensson_bay_variants.dart';
import 'f1050_svensson_bay_metadata.dart';

/// Svensson Bay — Strange Attractors.
class F1050SvenssonBay extends AttractorModule {
  F1050SvenssonBay()
      : super(
          id: 'f1050_svensson_bay',
          shader: 'shaders/f1050_svensson_bay_gpu.frag',
        );

  @override
  F1050SvenssonBayMetadata get metadata => F1050SvenssonBayMetadata.instance;

  @override
  List<F1050SvenssonBayPreset> get presets => F1050SvenssonBayPresets.all;

  @override
  List<F1050SvenssonBayVariant> get variants => F1050SvenssonBayVariants.all;

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
