// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1042_svensson_bloom_presets.dart';
import 'f1042_svensson_bloom_variants.dart';
import 'f1042_svensson_bloom_metadata.dart';

/// Svensson Bloom — Strange Attractors.
class F1042SvenssonBloom extends AttractorModule {
  F1042SvenssonBloom()
      : super(
          id: 'f1042_svensson_bloom',
          shader: 'shaders/f1042_svensson_bloom_gpu.frag',
        );

  @override
  F1042SvenssonBloomMetadata get metadata => F1042SvenssonBloomMetadata.instance;

  @override
  List<F1042SvenssonBloomPreset> get presets => F1042SvenssonBloomPresets.all;

  @override
  List<F1042SvenssonBloomVariant> get variants => F1042SvenssonBloomVariants.all;

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
