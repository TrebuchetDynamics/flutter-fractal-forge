// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0147_san_marco_julia_presets.dart';
import 'f0147_san_marco_julia_variants.dart';
import 'f0147_san_marco_julia_metadata.dart';

/// San Marco Julia — Escape-Time (Complex Plane).
class F0147SanMarcoJulia extends EscapeTimeModule {
  F0147SanMarcoJulia()
      : super(
          id: 'f0147_san_marco_julia',
          shader: 'shaders/escape_time_family/core/julia_gpu.frag',
        );

  @override
  F0147SanMarcoJuliaMetadata get metadata =>
      F0147SanMarcoJuliaMetadata.instance;

  @override
  List<F0147SanMarcoJuliaPreset> get presets => F0147SanMarcoJuliaPresets.all;

  @override
  List<F0147SanMarcoJuliaVariant> get variants =>
      F0147SanMarcoJuliaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 280;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.none;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
    p.setFloat('juliaCReal', -0.75);
    p.setFloat('juliaCImag', 0.0);
  }
}
