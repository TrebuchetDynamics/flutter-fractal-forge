// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1225_chebyshev_julia_t_3_presets.dart';
import 'f1225_chebyshev_julia_t_3_variants.dart';
import 'f1225_chebyshev_julia_t_3_metadata.dart';

/// Chebyshev Julia T_3 — Escape-Time (Complex Plane).
class F1225ChebyshevJuliaT3 extends EscapeTimeModule {
  F1225ChebyshevJuliaT3()
      : super(
          id: 'f1225_chebyshev_julia_t_3',
          shader: 'shaders/f1225_chebyshev_julia_t_3_gpu.frag',
        );

  @override
  F1225ChebyshevJuliaT3Metadata get metadata => F1225ChebyshevJuliaT3Metadata.instance;

  @override
  List<F1225ChebyshevJuliaT3Preset> get presets => F1225ChebyshevJuliaT3Presets.all;

  @override
  List<F1225ChebyshevJuliaT3Variant> get variants => F1225ChebyshevJuliaT3Variants.all;

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
