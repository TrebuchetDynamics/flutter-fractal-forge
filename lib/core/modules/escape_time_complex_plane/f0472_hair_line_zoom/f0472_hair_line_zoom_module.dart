// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0472_hair_line_zoom_presets.dart';
import 'f0472_hair_line_zoom_variants.dart';
import 'f0472_hair_line_zoom_metadata.dart';

/// Hair-Line Zoom — Escape-Time (Complex Plane).
class F0472HairLineZoom extends EscapeTimeModule {
  F0472HairLineZoom()
      : super(
          id: 'f0472_hair_line_zoom',
          shader: 'shaders/f0472_hair_line_zoom_gpu.frag',
        );

  @override
  F0472HairLineZoomMetadata get metadata => F0472HairLineZoomMetadata.instance;

  @override
  List<F0472HairLineZoomPreset> get presets => F0472HairLineZoomPresets.all;

  @override
  List<F0472HairLineZoomVariant> get variants => F0472HairLineZoomVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 15000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
