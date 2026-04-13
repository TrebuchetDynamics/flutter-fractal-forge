// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0536_eisenstein_series_presets.dart';
import 'f0536_eisenstein_series_variants.dart';
import 'f0536_eisenstein_series_metadata.dart';

/// Eisenstein Series — Escape-Time (Complex Plane).
class F0536EisensteinSeries extends EscapeTimeModule {
  F0536EisensteinSeries()
      : super(
          id: 'f0536_eisenstein_series',
          shader: 'shaders/f0536_eisenstein_series_gpu.frag',
        );

  @override
  F0536EisensteinSeriesMetadata get metadata => F0536EisensteinSeriesMetadata.instance;

  @override
  List<F0536EisensteinSeriesPreset> get presets => F0536EisensteinSeriesPresets.all;

  @override
  List<F0536EisensteinSeriesVariant> get variants => F0536EisensteinSeriesVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
