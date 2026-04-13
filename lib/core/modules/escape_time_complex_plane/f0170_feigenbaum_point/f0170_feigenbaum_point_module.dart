// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0170_feigenbaum_point_presets.dart';
import 'f0170_feigenbaum_point_variants.dart';
import 'f0170_feigenbaum_point_metadata.dart';

/// Feigenbaum Point — Escape-Time (Complex Plane).
class F0170FeigenbaumPoint extends EscapeTimeModule {
  F0170FeigenbaumPoint()
      : super(
          id: 'f0170_feigenbaum_point',
          shader: 'shaders/f0170_feigenbaum_point_gpu.frag',
        );

  @override
  F0170FeigenbaumPointMetadata get metadata => F0170FeigenbaumPointMetadata.instance;

  @override
  List<F0170FeigenbaumPointPreset> get presets => F0170FeigenbaumPointPresets.all;

  @override
  List<F0170FeigenbaumPointVariant> get variants => F0170FeigenbaumPointVariants.all;

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
