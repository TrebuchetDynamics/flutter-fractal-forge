// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0637_lyapunov_abababba_presets.dart';
import 'f0637_lyapunov_abababba_variants.dart';
import 'f0637_lyapunov_abababba_metadata.dart';

/// Lyapunov ABABABBA — Lyapunov & Stability.
class F0637LyapunovAbababba extends EscapeTimeModule {
  F0637LyapunovAbababba()
      : super(
          id: 'f0637_lyapunov_abababba',
          shader: 'shaders/f0637_lyapunov_abababba_gpu.frag',
        );

  @override
  F0637LyapunovAbababbaMetadata get metadata => F0637LyapunovAbababbaMetadata.instance;

  @override
  List<F0637LyapunovAbababbaPreset> get presets => F0637LyapunovAbababbaPresets.all;

  @override
  List<F0637LyapunovAbababbaVariant> get variants => F0637LyapunovAbababbaVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 2.0;

  @override
  int get defaultIterations => 300;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
