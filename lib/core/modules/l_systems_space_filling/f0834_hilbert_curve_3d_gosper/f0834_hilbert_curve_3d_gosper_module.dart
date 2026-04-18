// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0834_hilbert_curve_3d_gosper_presets.dart';
import 'f0834_hilbert_curve_3d_gosper_variants.dart';
import 'f0834_hilbert_curve_3d_gosper_metadata.dart';

/// Hilbert Curve 3D Gosper — L-Systems & Space-Filling.
class F0834HilbertCurve3dGosper extends LSystemModule {
  F0834HilbertCurve3dGosper()
      : super(
          id: 'f0834_hilbert_curve_3d_gosper',
          shader: 'shaders/f0834_hilbert_curve_3d_gosper_gpu.frag',
        );

  @override
  F0834HilbertCurve3dGosperMetadata get metadata => F0834HilbertCurve3dGosperMetadata.instance;

  @override
  List<F0834HilbertCurve3dGosperPreset> get presets => F0834HilbertCurve3dGosperPresets.all;

  @override
  List<F0834HilbertCurve3dGosperVariant> get variants => F0834HilbertCurve3dGosperVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
