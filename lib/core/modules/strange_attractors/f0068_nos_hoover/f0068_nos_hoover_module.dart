// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0068_nos_hoover_presets.dart';
import 'f0068_nos_hoover_variants.dart';
import 'f0068_nos_hoover_metadata.dart';

/// Nosé-Hoover — Strange Attractors.
class F0068NosHoover extends AttractorModule {
  F0068NosHoover()
      : super(
          id: 'f0068_nos_hoover',
          shader: 'shaders/f0068_nos_hoover_gpu.frag',
        );

  @override
  F0068NosHooverMetadata get metadata => F0068NosHooverMetadata.instance;

  @override
  List<F0068NosHooverPreset> get presets => F0068NosHooverPresets.all;

  @override
  List<F0068NosHooverVariant> get variants => F0068NosHooverVariants.all;

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
