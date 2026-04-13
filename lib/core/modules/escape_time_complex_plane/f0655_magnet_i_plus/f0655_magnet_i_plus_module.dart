// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0655_magnet_i_plus_presets.dart';
import 'f0655_magnet_i_plus_variants.dart';
import 'f0655_magnet_i_plus_metadata.dart';

/// Magnet I Plus — Escape-Time (Complex Plane).
class F0655MagnetIPlus extends EscapeTimeModule {
  F0655MagnetIPlus()
      : super(
          id: 'f0655_magnet_i_plus',
          shader: 'shaders/f0655_magnet_i_plus_gpu.frag',
        );

  @override
  F0655MagnetIPlusMetadata get metadata => F0655MagnetIPlusMetadata.instance;

  @override
  List<F0655MagnetIPlusPreset> get presets => F0655MagnetIPlusPresets.all;

  @override
  List<F0655MagnetIPlusVariant> get variants => F0655MagnetIPlusVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
