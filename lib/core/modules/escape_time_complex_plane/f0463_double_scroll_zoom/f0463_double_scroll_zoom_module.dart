// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0463_double_scroll_zoom_presets.dart';
import 'f0463_double_scroll_zoom_variants.dart';
import 'f0463_double_scroll_zoom_metadata.dart';

/// Double Scroll Zoom — Escape-Time (Complex Plane).
class F0463DoubleScrollZoom extends EscapeTimeModule {
  F0463DoubleScrollZoom()
      : super(
          id: 'f0463_double_scroll_zoom',
          shader: 'shaders/f0463_double_scroll_zoom_gpu.frag',
        );

  @override
  F0463DoubleScrollZoomMetadata get metadata => F0463DoubleScrollZoomMetadata.instance;

  @override
  List<F0463DoubleScrollZoomPreset> get presets => F0463DoubleScrollZoomPresets.all;

  @override
  List<F0463DoubleScrollZoomVariant> get variants => F0463DoubleScrollZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 2500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
