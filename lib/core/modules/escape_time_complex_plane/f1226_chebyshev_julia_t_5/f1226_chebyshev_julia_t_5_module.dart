// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1226_chebyshev_julia_t_5_presets.dart';
import 'f1226_chebyshev_julia_t_5_variants.dart';
import 'f1226_chebyshev_julia_t_5_metadata.dart';

/// Chebyshev Julia T_5 — Escape-Time (Complex Plane).
class F1226ChebyshevJuliaT5 extends EscapeTimeModule {
  F1226ChebyshevJuliaT5()
      : super(
          id: 'f1226_chebyshev_julia_t_5',
          shader: 'shaders/f1226_chebyshev_julia_t_5_gpu.frag',
        );

  @override
  F1226ChebyshevJuliaT5Metadata get metadata => F1226ChebyshevJuliaT5Metadata.instance;

  @override
  List<F1226ChebyshevJuliaT5Preset> get presets => F1226ChebyshevJuliaT5Presets.all;

  @override
  List<F1226ChebyshevJuliaT5Variant> get variants => F1226ChebyshevJuliaT5Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
