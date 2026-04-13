// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0613_lyapunov_aabb_presets.dart';
import 'f0613_lyapunov_aabb_variants.dart';
import 'f0613_lyapunov_aabb_metadata.dart';

/// Lyapunov AABB — Lyapunov & Stability.
class F0613LyapunovAabb extends EscapeTimeModule {
  F0613LyapunovAabb()
      : super(
          id: 'f0613_lyapunov_aabb',
          shader: 'shaders/f0613_lyapunov_aabb_gpu.frag',
        );

  @override
  F0613LyapunovAabbMetadata get metadata => F0613LyapunovAabbMetadata.instance;

  @override
  List<F0613LyapunovAabbPreset> get presets => F0613LyapunovAabbPresets.all;

  @override
  List<F0613LyapunovAabbVariant> get variants => F0613LyapunovAabbVariants.all;

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
