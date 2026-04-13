// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0632_lyapunov_aababba_presets.dart';
import 'f0632_lyapunov_aababba_variants.dart';
import 'f0632_lyapunov_aababba_metadata.dart';

/// Lyapunov AABABBA — Lyapunov & Stability.
class F0632LyapunovAababba extends EscapeTimeModule {
  F0632LyapunovAababba()
      : super(
          id: 'f0632_lyapunov_aababba',
          shader: 'shaders/f0632_lyapunov_aababba_gpu.frag',
        );

  @override
  F0632LyapunovAababbaMetadata get metadata => F0632LyapunovAababbaMetadata.instance;

  @override
  List<F0632LyapunovAababbaPreset> get presets => F0632LyapunovAababbaPresets.all;

  @override
  List<F0632LyapunovAababbaVariant> get variants => F0632LyapunovAababbaVariants.all;

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
