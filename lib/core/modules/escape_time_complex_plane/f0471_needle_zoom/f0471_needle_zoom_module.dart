// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0471_needle_zoom_presets.dart';
import 'f0471_needle_zoom_variants.dart';
import 'f0471_needle_zoom_metadata.dart';

/// Needle Zoom — Escape-Time (Complex Plane).
class F0471NeedleZoom extends EscapeTimeModule {
  F0471NeedleZoom()
      : super(
          id: 'f0471_needle_zoom',
          shader: 'shaders/f0471_needle_zoom_gpu.frag',
        );

  @override
  F0471NeedleZoomMetadata get metadata => F0471NeedleZoomMetadata.instance;

  @override
  List<F0471NeedleZoomPreset> get presets => F0471NeedleZoomPresets.all;

  @override
  List<F0471NeedleZoomVariant> get variants => F0471NeedleZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 10000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
