// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0477_heart_zoom_presets.dart';
import 'f0477_heart_zoom_variants.dart';
import 'f0477_heart_zoom_metadata.dart';

/// Heart Zoom — Escape-Time (Complex Plane).
class F0477HeartZoom extends EscapeTimeModule {
  F0477HeartZoom()
      : super(
          id: 'f0477_heart_zoom',
          shader: 'shaders/f0477_heart_zoom_gpu.frag',
        );

  @override
  F0477HeartZoomMetadata get metadata => F0477HeartZoomMetadata.instance;

  @override
  List<F0477HeartZoomPreset> get presets => F0477HeartZoomPresets.all;

  @override
  List<F0477HeartZoomVariant> get variants => F0477HeartZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
