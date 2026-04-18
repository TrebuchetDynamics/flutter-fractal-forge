// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1045_svensson_iris_presets.dart';
import 'f1045_svensson_iris_variants.dart';
import 'f1045_svensson_iris_metadata.dart';

/// Svensson Iris — Strange Attractors.
class F1045SvenssonIris extends AttractorModule {
  F1045SvenssonIris()
      : super(
          id: 'f1045_svensson_iris',
          shader: 'shaders/f1045_svensson_iris_gpu.frag',
        );

  @override
  F1045SvenssonIrisMetadata get metadata => F1045SvenssonIrisMetadata.instance;

  @override
  List<F1045SvenssonIrisPreset> get presets => F1045SvenssonIrisPresets.all;

  @override
  List<F1045SvenssonIrisVariant> get variants => F1045SvenssonIrisVariants.all;

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
