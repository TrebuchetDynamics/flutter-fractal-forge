// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0070_dequan_li_attractor_presets.dart';
import 'f0070_dequan_li_attractor_variants.dart';
import 'f0070_dequan_li_attractor_metadata.dart';

/// Dequan Li Attractor — Strange Attractors.
class F0070DequanLiAttractor extends AttractorModule {
  F0070DequanLiAttractor()
      : super(
          id: 'f0070_dequan_li_attractor',
          shader: 'shaders/f0070_dequan_li_attractor_gpu.frag',
        );

  @override
  F0070DequanLiAttractorMetadata get metadata => F0070DequanLiAttractorMetadata.instance;

  @override
  List<F0070DequanLiAttractorPreset> get presets => F0070DequanLiAttractorPresets.all;

  @override
  List<F0070DequanLiAttractorVariant> get variants => F0070DequanLiAttractorVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
