// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0833_hilbert_curve_3d_beta_presets.dart';
import 'f0833_hilbert_curve_3d_beta_variants.dart';
import 'f0833_hilbert_curve_3d_beta_metadata.dart';

/// Hilbert Curve 3D Beta — L-Systems & Space-Filling.
class F0833HilbertCurve3dBeta extends LSystemModule {
  F0833HilbertCurve3dBeta()
      : super(
          id: 'f0833_hilbert_curve_3d_beta',
          shader: 'shaders/f0833_hilbert_curve_3d_beta_gpu.frag',
        );

  @override
  F0833HilbertCurve3dBetaMetadata get metadata => F0833HilbertCurve3dBetaMetadata.instance;

  @override
  List<F0833HilbertCurve3dBetaPreset> get presets => F0833HilbertCurve3dBetaPresets.all;

  @override
  List<F0833HilbertCurve3dBetaVariant> get variants => F0833HilbertCurve3dBetaVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
