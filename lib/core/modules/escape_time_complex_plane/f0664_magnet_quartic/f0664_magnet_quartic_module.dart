// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0664_magnet_quartic_presets.dart';
import 'f0664_magnet_quartic_variants.dart';
import 'f0664_magnet_quartic_metadata.dart';

/// Magnet-Quartic — Escape-Time (Complex Plane).
class F0664MagnetQuartic extends EscapeTimeModule {
  F0664MagnetQuartic()
      : super(
          id: 'f0664_magnet_quartic',
          shader: 'shaders/f0664_magnet_quartic_gpu.frag',
        );

  @override
  F0664MagnetQuarticMetadata get metadata => F0664MagnetQuarticMetadata.instance;

  @override
  List<F0664MagnetQuarticPreset> get presets => F0664MagnetQuarticPresets.all;

  @override
  List<F0664MagnetQuarticVariant> get variants => F0664MagnetQuarticVariants.all;

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
