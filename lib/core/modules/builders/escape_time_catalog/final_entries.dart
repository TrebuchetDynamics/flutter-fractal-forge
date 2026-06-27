part of '../escape_time_catalog.dart';

final List<EscapeTimeConfig> _finalEntriesCatalog = [
// ── Final entries to reach 200 ─────────────────────────
  EscapeTimeConfig(
    id: 'hat_monotile',
    name: 'The Hat Monotile',
    shaderAsset: 'shaders/ifs_and_geometric/hat_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'spectre_monotile',
    name: 'The Spectre Monotile',
    shaderAsset: 'shaders/ifs_and_geometric/spectre_monotile_gpu.frag',
    defaultIterations: 120,
  ),
  EscapeTimeConfig(
    id: 'sphinx_tiling',
    name: 'Sphinx Tiling',
    shaderAsset: 'shaders/ifs_and_geometric/sphinx_tiling_gpu.frag',
    defaultIterations: 120,
  ),
];
