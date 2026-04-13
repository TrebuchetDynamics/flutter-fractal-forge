// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0143_dendrite_julia_presets.dart';
import 'f0143_dendrite_julia_variants.dart';
import 'f0143_dendrite_julia_metadata.dart';

/// Dendrite Julia — Escape-Time (Complex Plane).
class F0143DendriteJulia extends EscapeTimeModule {
  F0143DendriteJulia()
      : super(
          id: 'f0143_dendrite_julia',
          shader: 'shaders/f0143_dendrite_julia_gpu.frag',
        );

  @override
  F0143DendriteJuliaMetadata get metadata => F0143DendriteJuliaMetadata.instance;

  @override
  List<F0143DendriteJuliaPreset> get presets => F0143DendriteJuliaPresets.all;

  @override
  List<F0143DendriteJuliaVariant> get variants => F0143DendriteJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
