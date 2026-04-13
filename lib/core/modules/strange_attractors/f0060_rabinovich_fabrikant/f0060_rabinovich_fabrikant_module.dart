// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0060_rabinovich_fabrikant_presets.dart';
import 'f0060_rabinovich_fabrikant_variants.dart';
import 'f0060_rabinovich_fabrikant_metadata.dart';

/// Rabinovich-Fabrikant — Strange Attractors.
class F0060RabinovichFabrikant extends AttractorModule {
  F0060RabinovichFabrikant()
      : super(
          id: 'f0060_rabinovich_fabrikant',
          shader: 'shaders/f0060_rabinovich_fabrikant_gpu.frag',
        );

  @override
  F0060RabinovichFabrikantMetadata get metadata => F0060RabinovichFabrikantMetadata.instance;

  @override
  List<F0060RabinovichFabrikantPreset> get presets => F0060RabinovichFabrikantPresets.all;

  @override
  List<F0060RabinovichFabrikantVariant> get variants => F0060RabinovichFabrikantVariants.all;

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
