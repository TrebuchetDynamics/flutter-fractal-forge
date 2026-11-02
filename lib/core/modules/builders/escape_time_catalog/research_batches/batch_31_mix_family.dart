part of '../../escape_time_catalog.dart';

/// Two-term power mixtures, `z -> k*(a*z^b + d*z^f) + c`.
///
/// Source: "MandelbrotMix" formulas by Jim Muth in
/// `opensource/repos/formula-catalogs/fract4d-formulas/orgform/fotdv7.frm`
/// (MIT, commit 2b3e04b). The mathematics is adapted; no source text is copied.
/// Provenance: `opensource/docs/mandelbrot-mix-source.md`.
///
/// All entries share one shader and differ only in the mixture parameters.
/// `a = d = 0.5, b = f = 2, k = 1` reduces exactly to `z^2 + c`; the companion
/// test pins that identity so the family cannot drift away from its maths.
final List<EscapeTimeConfig> _batch31MixFamilyCatalog = [
  _mixEntry(
    id: 'mix_2_3',
    name: 'Mandelbrot Mix 2+3',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: 3.0,
    description: 'Quadratic and cubic terms compete; the plane shows mixed-degree bulbs.',
  ),
  _mixEntry(
    id: 'mix_2_4',
    name: 'Mandelbrot Mix 2+4',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: 4.0,
    description: 'Quartic term added to the quadratic map.',
  ),
  _mixEntry(
    id: 'mix_3_4',
    name: 'Mandelbrot Mix 3+4',
    a: 1.0,
    b: 3.0,
    d: 1.0,
    f: 4.0,
    description: 'Two high-order terms, no quadratic core.',
  ),
  _mixEntry(
    id: 'mix_2_25',
    name: 'Mandelbrot Mix 2+2.5',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: 2.5,
    description: 'Fractional second power between the quadratic and cubic maps.',
  ),
  _mixEntry(
    id: 'mix_15_2',
    name: 'Mandelbrot Mix 1.5+2',
    a: 1.0,
    b: 1.5,
    d: 1.0,
    f: 2.0,
    description: 'Sub-quadratic first term, the one-arm spiral regime.',
  ),
  _mixEntry(
    id: 'mix_2_neg2',
    name: 'Mandelbrot Mix 2-2',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: -2.0,
    description: 'Quadratic term plus an inverse-square pole.',
    zoom: 0.45,
  ),
  _mixEntry(
    id: 'mix_half_2_3',
    name: 'Half Mix 2+3',
    a: 0.5,
    b: 2.0,
    d: 0.5,
    f: 3.0,
    description: 'Halved amplitudes; the set shrinks toward the origin.',
  ),
  _mixEntry(
    id: 'mix_mandel_core',
    name: 'Mix Degenerate (Mandelbrot)',
    a: 0.5,
    b: 2.0,
    d: 0.5,
    f: 2.0,
    description: 'Both terms quadratic, the map reduces to z^2 + c.',
    zoom: 0.75,
  ),
  _juliaMixEntry(
    id: 'mix_julia_2_3',
    name: 'Mandelbrot Mix Julia 2+3',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: 3.0,
    cReal: 0.18,
    cImag: 0.0,
    description: 'Julia slice of the 2+3 mixture at c = 0.18.',
  ),
  _juliaMixEntry(
    id: 'mix_julia_dendrite',
    name: 'Mandelbrot Mix Julia Dendrite',
    a: 1.0,
    b: 2.0,
    d: 1.0,
    f: 3.0,
    cReal: -0.12,
    cImag: 0.74,
    description: 'Dendritic slice of the 2+3 mixture.',
  ),
];

EscapeTimeConfig _mixEntry({
  required String id,
  required String name,
  required double a,
  required double b,
  required double d,
  required double f,
  required String description,
  double zoom = 0.85,
  double k = 1.0,
}) {
  return EscapeTimeConfig(
    id: id,
    name: name,
    shaderAsset:
        'shaders/escape_time_family/families/mix/mandelbrot_mix_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 6,
    defaultColorScheme: 0,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: zoom,
    maxIterations: 500,
    category: 'Complex Dynamics',
    extraParams: [
      _floatParam(id: 'mixA', label: 'Term A Amplitude', min: -2, max: 2, step: 0.05, defaultValue: a),
      _floatParam(id: 'mixB', label: 'Term A Power', min: -4, max: 8, step: 0.05, defaultValue: b),
      _floatParam(id: 'mixD', label: 'Term D Amplitude', min: -2, max: 2, step: 0.05, defaultValue: d),
      _floatParam(id: 'mixF', label: 'Term D Power', min: -4, max: 8, step: 0.05, defaultValue: f),
      _floatParam(id: 'mixK', label: 'Scale', min: 0.1, max: 3, step: 0.05, defaultValue: k),
      _floatParam(id: 'juliaMode', label: 'Julia Mode', min: 0, max: 1, step: 1, defaultValue: 0),
      _floatParam(id: 'juliaReal', label: 'Julia Real', min: -2, max: 2, step: 0.01, defaultValue: 0),
      _floatParam(id: 'juliaImag', label: 'Julia Imag', min: -2, max: 2, step: 0.01, defaultValue: 0),
    ],
  );
}

EscapeTimeConfig _juliaMixEntry({
  required String id,
  required String name,
  required double a,
  required double b,
  required double d,
  required double f,
  required double cReal,
  required double cImag,
  required String description,
}) {
  return EscapeTimeConfig(
    id: id,
    name: name,
    shaderAsset:
        'shaders/escape_time_family/families/mix/mandelbrot_mix_gpu.frag',
    defaultIterations: 160,
    defaultBailout: 6,
    defaultColorScheme: 2,
    defaultCenterX: 0,
    defaultCenterY: 0,
    defaultZoom: 0.9,
    maxIterations: 500,
    category: 'Complex Dynamics',
    extraParams: [
      _floatParam(id: 'mixA', label: 'Term A Amplitude', min: -2, max: 2, step: 0.05, defaultValue: a),
      _floatParam(id: 'mixB', label: 'Term A Power', min: -4, max: 8, step: 0.05, defaultValue: b),
      _floatParam(id: 'mixD', label: 'Term D Amplitude', min: -2, max: 2, step: 0.05, defaultValue: d),
      _floatParam(id: 'mixF', label: 'Term D Power', min: -4, max: 8, step: 0.05, defaultValue: f),
      _floatParam(id: 'mixK', label: 'Scale', min: 0.1, max: 3, step: 0.05, defaultValue: 1),
      _floatParam(id: 'juliaMode', label: 'Julia Mode', min: 0, max: 1, step: 1, defaultValue: 1),
      _floatParam(id: 'juliaReal', label: 'Julia Real', min: -2, max: 2, step: 0.01, defaultValue: cReal),
      _floatParam(id: 'juliaImag', label: 'Julia Imag', min: -2, max: 2, step: 0.01, defaultValue: cImag),
    ],
  );
}
