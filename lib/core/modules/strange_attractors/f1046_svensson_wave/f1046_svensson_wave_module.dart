// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1046_svensson_wave_presets.dart';
import 'f1046_svensson_wave_variants.dart';
import 'f1046_svensson_wave_metadata.dart';

/// Svensson Wave — Strange Attractors.
class F1046SvenssonWave extends AttractorModule {
  F1046SvenssonWave()
      : super(
          id: 'f1046_svensson_wave',
          shader: 'shaders/f1046_svensson_wave_gpu.frag',
        );

  @override
  F1046SvenssonWaveMetadata get metadata => F1046SvenssonWaveMetadata.instance;

  @override
  List<F1046SvenssonWavePreset> get presets => F1046SvenssonWavePresets.all;

  @override
  List<F1046SvenssonWaveVariant> get variants => F1046SvenssonWaveVariants.all;

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
