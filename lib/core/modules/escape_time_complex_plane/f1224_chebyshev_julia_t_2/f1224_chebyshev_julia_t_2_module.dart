// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1224_chebyshev_julia_t_2_presets.dart';
import 'f1224_chebyshev_julia_t_2_variants.dart';
import 'f1224_chebyshev_julia_t_2_metadata.dart';

/// Chebyshev Julia T_2 — Escape-Time (Complex Plane).
class F1224ChebyshevJuliaT2 extends EscapeTimeModule {
  F1224ChebyshevJuliaT2()
      : super(
          id: 'f1224_chebyshev_julia_t_2',
          shader: 'shaders/f1224_chebyshev_julia_t_2_gpu.frag',
        );

  @override
  F1224ChebyshevJuliaT2Metadata get metadata => F1224ChebyshevJuliaT2Metadata.instance;

  @override
  List<F1224ChebyshevJuliaT2Preset> get presets => F1224ChebyshevJuliaT2Presets.all;

  @override
  List<F1224ChebyshevJuliaT2Variant> get variants => F1224ChebyshevJuliaT2Variants.all;

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
