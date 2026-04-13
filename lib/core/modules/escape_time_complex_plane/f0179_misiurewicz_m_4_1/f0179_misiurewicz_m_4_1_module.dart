// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0179_misiurewicz_m_4_1_presets.dart';
import 'f0179_misiurewicz_m_4_1_variants.dart';
import 'f0179_misiurewicz_m_4_1_metadata.dart';

/// Misiurewicz M_{4,1} — Escape-Time (Complex Plane).
class F0179MisiurewiczM41 extends EscapeTimeModule {
  F0179MisiurewiczM41()
      : super(
          id: 'f0179_misiurewicz_m_4_1',
          shader: 'shaders/f0179_misiurewicz_m_4_1_gpu.frag',
        );

  @override
  F0179MisiurewiczM41Metadata get metadata => F0179MisiurewiczM41Metadata.instance;

  @override
  List<F0179MisiurewiczM41Preset> get presets => F0179MisiurewiczM41Presets.all;

  @override
  List<F0179MisiurewiczM41Variant> get variants => F0179MisiurewiczM41Variants.all;

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
