// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0464_filament_threads_presets.dart';
import 'f0464_filament_threads_variants.dart';
import 'f0464_filament_threads_metadata.dart';

/// Filament Threads — Escape-Time (Complex Plane).
class F0464FilamentThreads extends EscapeTimeModule {
  F0464FilamentThreads()
      : super(
          id: 'f0464_filament_threads',
          shader: 'shaders/f0464_filament_threads_gpu.frag',
        );

  @override
  F0464FilamentThreadsMetadata get metadata => F0464FilamentThreadsMetadata.instance;

  @override
  List<F0464FilamentThreadsPreset> get presets => F0464FilamentThreadsPresets.all;

  @override
  List<F0464FilamentThreadsVariant> get variants => F0464FilamentThreadsVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 5000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
