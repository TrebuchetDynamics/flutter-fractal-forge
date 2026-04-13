// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0166_chebyshev_julia_presets.dart';
import 'f0166_chebyshev_julia_variants.dart';
import 'f0166_chebyshev_julia_metadata.dart';

/// Chebyshev Julia — Escape-Time (Complex Plane).
class F0166ChebyshevJulia extends EscapeTimeModule {
  F0166ChebyshevJulia()
      : super(
          id: 'f0166_chebyshev_julia',
          shader: 'shaders/f0166_chebyshev_julia_gpu.frag',
        );

  @override
  F0166ChebyshevJuliaMetadata get metadata => F0166ChebyshevJuliaMetadata.instance;

  @override
  List<F0166ChebyshevJuliaPreset> get presets => F0166ChebyshevJuliaPresets.all;

  @override
  List<F0166ChebyshevJuliaVariant> get variants => F0166ChebyshevJuliaVariants.all;

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
