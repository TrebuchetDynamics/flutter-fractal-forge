// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0026_sprott_m_presets.dart';
import 'f0026_sprott_m_variants.dart';
import 'f0026_sprott_m_metadata.dart';

/// Sprott M — Strange Attractors.
class F0026SprottM extends AttractorModule {
  F0026SprottM()
      : super(
          id: 'f0026_sprott_m',
          shader: 'shaders/f0026_sprott_m_gpu.frag',
        );

  @override
  F0026SprottMMetadata get metadata => F0026SprottMMetadata.instance;

  @override
  List<F0026SprottMPreset> get presets => F0026SprottMPresets.all;

  @override
  List<F0026SprottMVariant> get variants => F0026SprottMVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
