// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0454_main_cardioid_cusp_presets.dart';
import 'f0454_main_cardioid_cusp_variants.dart';
import 'f0454_main_cardioid_cusp_metadata.dart';

/// Main Cardioid Cusp — Escape-Time (Complex Plane).
class F0454MainCardioidCusp extends EscapeTimeModule {
  F0454MainCardioidCusp()
      : super(
          id: 'f0454_main_cardioid_cusp',
          shader: 'shaders/f0454_main_cardioid_cusp_gpu.frag',
        );

  @override
  F0454MainCardioidCuspMetadata get metadata => F0454MainCardioidCuspMetadata.instance;

  @override
  List<F0454MainCardioidCuspPreset> get presets => F0454MainCardioidCuspPresets.all;

  @override
  List<F0454MainCardioidCuspVariant> get variants => F0454MainCardioidCuspVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

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
