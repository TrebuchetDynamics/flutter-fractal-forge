// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0426_seahorse_tail_zoom_presets.dart';
import 'f0426_seahorse_tail_zoom_variants.dart';
import 'f0426_seahorse_tail_zoom_metadata.dart';

/// Seahorse Tail Zoom — Escape-Time (Complex Plane).
class F0426SeahorseTailZoom extends EscapeTimeModule {
  F0426SeahorseTailZoom()
      : super(
          id: 'f0426_seahorse_tail_zoom',
          shader: 'shaders/f0426_seahorse_tail_zoom_gpu.frag',
        );

  @override
  F0426SeahorseTailZoomMetadata get metadata => F0426SeahorseTailZoomMetadata.instance;

  @override
  List<F0426SeahorseTailZoomPreset> get presets => F0426SeahorseTailZoomPresets.all;

  @override
  List<F0426SeahorseTailZoomVariant> get variants => F0426SeahorseTailZoomVariants.all;

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
