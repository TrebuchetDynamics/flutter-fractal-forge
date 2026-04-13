// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0183_critical_period_3_presets.dart';
import 'f0183_critical_period_3_variants.dart';
import 'f0183_critical_period_3_metadata.dart';

/// Critical Period-3 — Escape-Time (Complex Plane).
class F0183CriticalPeriod3 extends EscapeTimeModule {
  F0183CriticalPeriod3()
      : super(
          id: 'f0183_critical_period_3',
          shader: 'shaders/f0183_critical_period_3_gpu.frag',
        );

  @override
  F0183CriticalPeriod3Metadata get metadata => F0183CriticalPeriod3Metadata.instance;

  @override
  List<F0183CriticalPeriod3Preset> get presets => F0183CriticalPeriod3Presets.all;

  @override
  List<F0183CriticalPeriod3Variant> get variants => F0183CriticalPeriod3Variants.all;

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
