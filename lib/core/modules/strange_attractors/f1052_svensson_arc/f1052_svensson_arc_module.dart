// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1052_svensson_arc_presets.dart';
import 'f1052_svensson_arc_variants.dart';
import 'f1052_svensson_arc_metadata.dart';

/// Svensson Arc — Strange Attractors.
class F1052SvenssonArc extends AttractorModule {
  F1052SvenssonArc()
      : super(
          id: 'f1052_svensson_arc',
          shader: 'shaders/f1052_svensson_arc_gpu.frag',
        );

  @override
  F1052SvenssonArcMetadata get metadata => F1052SvenssonArcMetadata.instance;

  @override
  List<F1052SvenssonArcPreset> get presets => F1052SvenssonArcPresets.all;

  @override
  List<F1052SvenssonArcVariant> get variants => F1052SvenssonArcVariants.all;

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
