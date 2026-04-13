// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0450_feigenbaum_point_presets.dart';
import 'f0450_feigenbaum_point_variants.dart';
import 'f0450_feigenbaum_point_metadata.dart';

/// Feigenbaum Point — Escape-Time (Complex Plane).
class F0450FeigenbaumPoint extends EscapeTimeModule {
  F0450FeigenbaumPoint()
      : super(
          id: 'f0450_feigenbaum_point',
          shader: 'shaders/f0450_feigenbaum_point_gpu.frag',
        );

  @override
  F0450FeigenbaumPointMetadata get metadata => F0450FeigenbaumPointMetadata.instance;

  @override
  List<F0450FeigenbaumPointPreset> get presets => F0450FeigenbaumPointPresets.all;

  @override
  List<F0450FeigenbaumPointVariant> get variants => F0450FeigenbaumPointVariants.all;

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
