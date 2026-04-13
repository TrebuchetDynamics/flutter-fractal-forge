// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0229_hilbert_curve_3d_presets.dart';
import 'f0229_hilbert_curve_3d_variants.dart';
import 'f0229_hilbert_curve_3d_metadata.dart';

/// Hilbert Curve 3D — L-Systems & Space-Filling.
class F0229HilbertCurve3d extends LSystemModule {
  F0229HilbertCurve3d()
      : super(
          id: 'f0229_hilbert_curve_3d',
          shader: 'shaders/f0229_hilbert_curve_3d_gpu.frag',
        );

  @override
  F0229HilbertCurve3dMetadata get metadata => F0229HilbertCurve3dMetadata.instance;

  @override
  List<F0229HilbertCurve3dPreset> get presets => F0229HilbertCurve3dPresets.all;

  @override
  List<F0229HilbertCurve3dVariant> get variants => F0229HilbertCurve3dVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
