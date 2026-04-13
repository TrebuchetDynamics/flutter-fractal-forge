// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0145_seahorse_valley_julia_presets.dart';
import 'f0145_seahorse_valley_julia_variants.dart';
import 'f0145_seahorse_valley_julia_metadata.dart';

/// Seahorse Valley Julia — Escape-Time (Complex Plane).
class F0145SeahorseValleyJulia extends EscapeTimeModule {
  F0145SeahorseValleyJulia()
      : super(
          id: 'f0145_seahorse_valley_julia',
          shader: 'shaders/f0145_seahorse_valley_julia_gpu.frag',
        );

  @override
  F0145SeahorseValleyJuliaMetadata get metadata => F0145SeahorseValleyJuliaMetadata.instance;

  @override
  List<F0145SeahorseValleyJuliaPreset> get presets => F0145SeahorseValleyJuliaPresets.all;

  @override
  List<F0145SeahorseValleyJuliaVariant> get variants => F0145SeahorseValleyJuliaVariants.all;

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
