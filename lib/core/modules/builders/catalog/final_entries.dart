import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';

/// Final entries to complete the 200-fractal collection.
///
/// Contains monotile and special tiling fractals.

final List<EscapeTimeConfig> finalEntries = [
  EscapeTimeConfig(
    id: 'hat_monotile',
    name: 'The Hat Monotile',
    shaderAsset: 'shaders/hat_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'spectre_monotile',
    name: 'The Spectre Monotile',
    shaderAsset: 'shaders/spectre_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'sphinx_tiling',
    name: 'Sphinx Tiling',
    shaderAsset: 'shaders/sphinx_tiling_gpu.frag',
    defaultIterations: 120,
  ),
];
