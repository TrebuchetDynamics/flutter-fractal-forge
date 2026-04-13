// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0185_thistle_julia_presets.dart';
import 'f0185_thistle_julia_variants.dart';
import 'f0185_thistle_julia_metadata.dart';

/// Thistle Julia — Escape-Time (Complex Plane).
class F0185ThistleJulia extends EscapeTimeModule {
  F0185ThistleJulia()
      : super(
          id: 'f0185_thistle_julia',
          shader: 'shaders/f0185_thistle_julia_gpu.frag',
        );

  @override
  F0185ThistleJuliaMetadata get metadata => F0185ThistleJuliaMetadata.instance;

  @override
  List<F0185ThistleJuliaPreset> get presets => F0185ThistleJuliaPresets.all;

  @override
  List<F0185ThistleJuliaVariant> get variants => F0185ThistleJuliaVariants.all;

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
