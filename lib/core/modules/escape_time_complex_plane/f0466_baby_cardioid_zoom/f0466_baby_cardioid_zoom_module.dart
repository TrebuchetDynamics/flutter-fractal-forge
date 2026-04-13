// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0466_baby_cardioid_zoom_presets.dart';
import 'f0466_baby_cardioid_zoom_variants.dart';
import 'f0466_baby_cardioid_zoom_metadata.dart';

/// Baby Cardioid Zoom — Escape-Time (Complex Plane).
class F0466BabyCardioidZoom extends EscapeTimeModule {
  F0466BabyCardioidZoom()
      : super(
          id: 'f0466_baby_cardioid_zoom',
          shader: 'shaders/f0466_baby_cardioid_zoom_gpu.frag',
        );

  @override
  F0466BabyCardioidZoomMetadata get metadata => F0466BabyCardioidZoomMetadata.instance;

  @override
  List<F0466BabyCardioidZoomPreset> get presets => F0466BabyCardioidZoomPresets.all;

  @override
  List<F0466BabyCardioidZoomVariant> get variants => F0466BabyCardioidZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
