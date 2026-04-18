// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0837_peano_gosper_curve_presets.dart';
import 'f0837_peano_gosper_curve_variants.dart';
import 'f0837_peano_gosper_curve_metadata.dart';

/// Peano-Gosper Curve — L-Systems & Space-Filling.
class F0837PeanoGosperCurve extends LSystemModule {
  F0837PeanoGosperCurve()
      : super(
          id: 'f0837_peano_gosper_curve',
          shader: 'shaders/f0837_peano_gosper_curve_gpu.frag',
        );

  @override
  F0837PeanoGosperCurveMetadata get metadata => F0837PeanoGosperCurveMetadata.instance;

  @override
  List<F0837PeanoGosperCurvePreset> get presets => F0837PeanoGosperCurvePresets.all;

  @override
  List<F0837PeanoGosperCurveVariant> get variants => F0837PeanoGosperCurveVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
