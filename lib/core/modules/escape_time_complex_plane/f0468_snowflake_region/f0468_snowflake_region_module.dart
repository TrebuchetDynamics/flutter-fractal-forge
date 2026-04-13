// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0468_snowflake_region_presets.dart';
import 'f0468_snowflake_region_variants.dart';
import 'f0468_snowflake_region_metadata.dart';

/// Snowflake Region — Escape-Time (Complex Plane).
class F0468SnowflakeRegion extends EscapeTimeModule {
  F0468SnowflakeRegion()
      : super(
          id: 'f0468_snowflake_region',
          shader: 'shaders/f0468_snowflake_region_gpu.frag',
        );

  @override
  F0468SnowflakeRegionMetadata get metadata => F0468SnowflakeRegionMetadata.instance;

  @override
  List<F0468SnowflakeRegionPreset> get presets => F0468SnowflakeRegionPresets.all;

  @override
  List<F0468SnowflakeRegionVariant> get variants => F0468SnowflakeRegionVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 3000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
