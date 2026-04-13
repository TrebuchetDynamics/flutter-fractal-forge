// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0173_mini_brot_julia_presets.dart';
import 'f0173_mini_brot_julia_variants.dart';
import 'f0173_mini_brot_julia_metadata.dart';

/// Mini-Brot Julia — Escape-Time (Complex Plane).
class F0173MiniBrotJulia extends EscapeTimeModule {
  F0173MiniBrotJulia()
      : super(
          id: 'f0173_mini_brot_julia',
          shader: 'shaders/f0173_mini_brot_julia_gpu.frag',
        );

  @override
  F0173MiniBrotJuliaMetadata get metadata => F0173MiniBrotJuliaMetadata.instance;

  @override
  List<F0173MiniBrotJuliaPreset> get presets => F0173MiniBrotJuliaPresets.all;

  @override
  List<F0173MiniBrotJuliaVariant> get variants => F0173MiniBrotJuliaVariants.all;

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
