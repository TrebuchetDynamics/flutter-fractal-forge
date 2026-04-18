// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1230_satsuma_rational_map_presets.dart';
import 'f1230_satsuma_rational_map_variants.dart';
import 'f1230_satsuma_rational_map_metadata.dart';

/// Satsuma Rational Map — Escape-Time (Complex Plane).
class F1230SatsumaRationalMap extends EscapeTimeModule {
  F1230SatsumaRationalMap()
      : super(
          id: 'f1230_satsuma_rational_map',
          shader: 'shaders/f1230_satsuma_rational_map_gpu.frag',
        );

  @override
  F1230SatsumaRationalMapMetadata get metadata => F1230SatsumaRationalMapMetadata.instance;

  @override
  List<F1230SatsumaRationalMapPreset> get presets => F1230SatsumaRationalMapPresets.all;

  @override
  List<F1230SatsumaRationalMapVariant> get variants => F1230SatsumaRationalMapVariants.all;

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
