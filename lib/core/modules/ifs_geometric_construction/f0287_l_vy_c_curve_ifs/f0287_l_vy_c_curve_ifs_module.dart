// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0287_l_vy_c_curve_ifs_presets.dart';
import 'f0287_l_vy_c_curve_ifs_variants.dart';
import 'f0287_l_vy_c_curve_ifs_metadata.dart';

/// Lévy C Curve IFS — IFS & Geometric Construction.
class F0287LVyCCurveIfs extends IFSModule {
  F0287LVyCCurveIfs()
      : super(
          id: 'f0287_l_vy_c_curve_ifs',
          shader: 'shaders/f0287_l_vy_c_curve_ifs_gpu.frag',
        );

  @override
  F0287LVyCCurveIfsMetadata get metadata => F0287LVyCCurveIfsMetadata.instance;

  @override
  List<F0287LVyCCurveIfsPreset> get presets => F0287LVyCCurveIfsPresets.all;

  @override
  List<F0287LVyCCurveIfsVariant> get variants => F0287LVyCCurveIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
