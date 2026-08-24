part of '../escape_time_catalog.dart';

List<FractalParameter> _logPolarTessellationParams({
  required double formula,
  required double motif,
  required double juliaReal,
  required double juliaImag,
  required double angularRepeats,
  required double radialRepeats,
  double phaseOffset = 0,
}) =>
    [
      _floatParam(
        id: 'formula',
        label: 'Fractal Formula',
        min: 0,
        max: 3,
        step: 1,
        defaultValue: formula,
      ),
      _floatParam(
        id: 'motif',
        label: 'Tile Motif',
        min: 0,
        max: 3,
        step: 1,
        defaultValue: motif,
      ),
      _floatParam(
        id: 'juliaReal',
        label: 'Julia c Re',
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: juliaReal,
      ),
      _floatParam(
        id: 'juliaImag',
        label: 'Julia c Im',
        min: -1.5,
        max: 1.5,
        step: 0.01,
        defaultValue: juliaImag,
      ),
      _floatParam(
        id: 'angularRepeats',
        label: 'Angular Repeats',
        min: 1,
        max: 12,
        step: 1,
        defaultValue: angularRepeats,
      ),
      _floatParam(
        id: 'radialRepeats',
        label: 'Radial Repeats',
        min: 1,
        max: 16,
        step: 1,
        defaultValue: radialRepeats,
      ),
      _floatParam(
        id: 'phaseOffset',
        label: 'Tile Phase',
        min: -1,
        max: 1,
        step: 0.01,
        defaultValue: phaseOffset,
      ),
    ];

/// Log-polar escape tessellations inspired by the public mathematical sketch
/// documented in `research/log-polar-fractal-tessellation/report.md`.
///
/// The source post used arbitrary image tiles. These production variants use
/// original procedural motifs instead, so no third-party imagery is bundled.
final List<EscapeTimeConfig> _batch27LogPolarTessellationsCatalog = [
  EscapeTimeConfig(
    id: 'mandelbrot_log_polar_tessellation',
    name: 'Mandelbrot Log-Polar Tessellation',
    shaderAsset:
        'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
    defaultIterations: 140,
    defaultBailout: 8,
    defaultColorScheme: 7,
    defaultCenterX: -0.5,
    defaultCenterY: 0,
    defaultZoom: 0.72,
    maxIterations: 300,
    category: 'Image Tessellations',
    extraParams: _logPolarTessellationParams(
      formula: 0,
      motif: 0,
      juliaReal: -0.745,
      juliaImag: 0.113,
      angularRepeats: 5,
      radialRepeats: 7,
    ),
  ),
  EscapeTimeConfig(
    id: 'julia_log_polar_tessellation',
    name: 'Julia Log-Polar Tessellation',
    shaderAsset:
        'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8,
    defaultColorScheme: 18,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: 0.82,
    maxIterations: 300,
    category: 'Image Tessellations',
    extraParams: _logPolarTessellationParams(
      formula: 1,
      motif: 1,
      juliaReal: -0.745,
      juliaImag: 0.113,
      angularRepeats: 6,
      radialRepeats: 8,
      phaseOffset: 0.08,
    ),
  ),
  EscapeTimeConfig(
    id: 'burning_ship_log_polar_tessellation',
    name: 'Burning Ship Log-Polar Tessellation',
    shaderAsset:
        'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 8,
    defaultColorScheme: 29,
    defaultCenterX: -0.46,
    defaultCenterY: -0.52,
    defaultZoom: 0.72,
    maxIterations: 300,
    category: 'Image Tessellations',
    extraParams: _logPolarTessellationParams(
      formula: 2,
      motif: 2,
      juliaReal: -0.745,
      juliaImag: 0.113,
      angularRepeats: 4,
      radialRepeats: 9,
      phaseOffset: -0.12,
    ),
  ),
  EscapeTimeConfig(
    id: 'tricorn_log_polar_tessellation',
    name: 'Tricorn Log-Polar Tessellation',
    shaderAsset:
        'shaders/escape_time_family/textured/log_polar_tessellation_gpu.frag',
    defaultIterations: 150,
    defaultBailout: 8,
    defaultColorScheme: 43,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: 0.68,
    maxIterations: 300,
    category: 'Image Tessellations',
    extraParams: _logPolarTessellationParams(
      formula: 3,
      motif: 3,
      juliaReal: -0.745,
      juliaImag: 0.113,
      angularRepeats: 7,
      radialRepeats: 6,
      phaseOffset: 0.16,
    ),
  ),
];
