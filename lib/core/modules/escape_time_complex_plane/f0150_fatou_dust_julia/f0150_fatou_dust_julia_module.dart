// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0150_fatou_dust_julia_presets.dart';
import 'f0150_fatou_dust_julia_variants.dart';
import 'f0150_fatou_dust_julia_metadata.dart';

/// Fatou Dust Julia — Escape-Time (Complex Plane).
class F0150FatouDustJulia extends EscapeTimeModule {
  F0150FatouDustJulia()
      : super(
          id: 'f0150_fatou_dust_julia',
          shader: 'shaders/f0150_fatou_dust_julia_gpu.frag',
        );

  @override
  F0150FatouDustJuliaMetadata get metadata => F0150FatouDustJuliaMetadata.instance;

  @override
  List<F0150FatouDustJuliaPreset> get presets => F0150FatouDustJuliaPresets.all;

  @override
  List<F0150FatouDustJuliaVariant> get variants => F0150FatouDustJuliaVariants.all;

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
