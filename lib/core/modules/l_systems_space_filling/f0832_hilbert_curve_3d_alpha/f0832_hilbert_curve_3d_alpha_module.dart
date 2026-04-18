// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0832_hilbert_curve_3d_alpha_presets.dart';
import 'f0832_hilbert_curve_3d_alpha_variants.dart';
import 'f0832_hilbert_curve_3d_alpha_metadata.dart';

/// Hilbert Curve 3D Alpha — L-Systems & Space-Filling.
class F0832HilbertCurve3dAlpha extends LSystemModule {
  F0832HilbertCurve3dAlpha()
      : super(
          id: 'f0832_hilbert_curve_3d_alpha',
          shader: 'shaders/f0832_hilbert_curve_3d_alpha_gpu.frag',
        );

  @override
  F0832HilbertCurve3dAlphaMetadata get metadata => F0832HilbertCurve3dAlphaMetadata.instance;

  @override
  List<F0832HilbertCurve3dAlphaPreset> get presets => F0832HilbertCurve3dAlphaPresets.all;

  @override
  List<F0832HilbertCurve3dAlphaVariant> get variants => F0832HilbertCurve3dAlphaVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
