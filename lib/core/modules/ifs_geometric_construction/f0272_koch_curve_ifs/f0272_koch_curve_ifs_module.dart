// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0272_koch_curve_ifs_presets.dart';
import 'f0272_koch_curve_ifs_variants.dart';
import 'f0272_koch_curve_ifs_metadata.dart';

/// Koch Curve IFS — IFS & Geometric Construction.
class F0272KochCurveIfs extends IFSModule {
  F0272KochCurveIfs()
      : super(
          id: 'f0272_koch_curve_ifs',
          shader: 'shaders/f0272_koch_curve_ifs_gpu.frag',
        );

  @override
  F0272KochCurveIfsMetadata get metadata => F0272KochCurveIfsMetadata.instance;

  @override
  List<F0272KochCurveIfsPreset> get presets => F0272KochCurveIfsPresets.all;

  @override
  List<F0272KochCurveIfsVariant> get variants => F0272KochCurveIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
