// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0189_medusa_julia_presets.dart';
import 'f0189_medusa_julia_variants.dart';
import 'f0189_medusa_julia_metadata.dart';

/// Medusa Julia — Escape-Time (Complex Plane).
class F0189MedusaJulia extends EscapeTimeModule {
  F0189MedusaJulia()
      : super(
          id: 'f0189_medusa_julia',
          shader: 'shaders/f0189_medusa_julia_gpu.frag',
        );

  @override
  F0189MedusaJuliaMetadata get metadata => F0189MedusaJuliaMetadata.instance;

  @override
  List<F0189MedusaJuliaPreset> get presets => F0189MedusaJuliaPresets.all;

  @override
  List<F0189MedusaJuliaVariant> get variants => F0189MedusaJuliaVariants.all;

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
